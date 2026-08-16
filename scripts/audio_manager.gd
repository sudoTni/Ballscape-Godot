extends Node

# Procedural Retro Sound Effects Synthesizer for Ballscape
var players: Array[AudioStreamPlayer] = []
const MAX_PLAYERS: int = 8
var current_player: int = 0

# Cached audio streams
var sfx_cache: Dictionary = {}

func _ready() -> void:
	# Create pool of AudioStreamPlayers
	for i in range(MAX_PLAYERS):
		var p = AudioStreamPlayer.new()
		p.bus = &"Master"
		add_child(p)
		players.append(p)
		
	# Generate procedural WAV SFX
	_generate_all_sfx()

func _generate_all_sfx() -> void:
	sfx_cache["bounce"] = _synth_sine_sweep(440, 220, 0.08)
	sfx_cache["brick_hit"] = _synth_square(880, 0.06, 0.3)
	sfx_cache["brick_destroy"] = _synth_noise(0.12, 0.4)
	sfx_cache["explosion"] = _synth_low_explosion(0.35)
	sfx_cache["powerup"] = _synth_arpeggio([523, 659, 784, 1046], 0.05)
	sfx_cache["laser"] = _synth_laser_sweep(1200, 300, 0.1)
	sfx_cache["lose_life"] = _synth_sine_sweep(400, 100, 0.35)
	sfx_cache["level_clear"] = _synth_arpeggio([523, 659, 784, 1046, 1318], 0.08)
	sfx_cache["click"] = _synth_square(600, 0.03, 0.2)

func play_sfx(name: String) -> void:
	if not Global.sound_enabled:
		return
	if sfx_cache.has(name):
		var p = players[current_player]
		current_player = (current_player + 1) % MAX_PLAYERS
		p.stream = sfx_cache[name]
		p.play()

# Audio Synthesis Generators
func _synth_sine_sweep(freq_start: float, freq_end: float, duration: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var num_samples: int = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / float(num_samples)
		var freq: float = lerp(freq_start, freq_end, t)
		var env: float = 1.0 - t
		var phase: float = float(i) * freq / float(sample_rate) * TAU
		var sample_val: int = int(sin(phase) * 16000.0 * env)
		sample_val = clampi(sample_val, -32768, 32767)
		
		var idx: int = i * 2
		data[idx] = sample_val & 0xFF
		data[idx + 1] = (sample_val >> 8) & 0xFF
		
	return _make_wav(data, sample_rate)

func _synth_square(freq: float, duration: float, volume: float = 0.5) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var num_samples: int = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	var period: float = float(sample_rate) / freq
	for i in range(num_samples):
		var env: float = 1.0 - (float(i) / float(num_samples))
		var wave: float = 1.0 if fmod(float(i), period) < (period * 0.5) else -1.0
		var sample_val: int = int(wave * 20000.0 * volume * env)
		sample_val = clampi(sample_val, -32768, 32767)
		
		var idx: int = i * 2
		data[idx] = sample_val & 0xFF
		data[idx + 1] = (sample_val >> 8) & 0xFF
		
	return _make_wav(data, sample_rate)

func _synth_noise(duration: float, volume: float = 0.5) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var num_samples: int = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 12345
	for i in range(num_samples):
		var env: float = 1.0 - (float(i) / float(num_samples))
		var n: float = rng.randf_range(-1.0, 1.0)
		var sample_val: int = int(n * 24000.0 * volume * env)
		sample_val = clampi(sample_val, -32768, 32767)
		
		var idx: int = i * 2
		data[idx] = sample_val & 0xFF
		data[idx + 1] = (sample_val >> 8) & 0xFF
		
	return _make_wav(data, sample_rate)

func _synth_low_explosion(duration: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var num_samples: int = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 6789
	var last_val: float = 0.0
	for i in range(num_samples):
		var env: float = 1.0 - (float(i) / float(num_samples))
		var n: float = rng.randf_range(-1.0, 1.0)
		# Lowpass filter for deep boom sound
		last_val = lerp(last_val, n, 0.25)
		var sample_val: int = int(last_val * 28000.0 * env)
		sample_val = clampi(sample_val, -32768, 32767)
		
		var idx: int = i * 2
		data[idx] = sample_val & 0xFF
		data[idx + 1] = (sample_val >> 8) & 0xFF
		
	return _make_wav(data, sample_rate)

func _synth_laser_sweep(freq_start: float, freq_end: float, duration: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var num_samples: int = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / float(num_samples)
		var freq: float = lerp(freq_start, freq_end, t * t)
		var env: float = 1.0 - t
		var phase: float = float(i) * freq / float(sample_rate) * TAU
		var wave: float = 1.0 if fmod(phase, TAU) < PI else -1.0
		var sample_val: int = int(wave * 18000.0 * env)
		sample_val = clampi(sample_val, -32768, 32767)
		
		var idx: int = i * 2
		data[idx] = sample_val & 0xFF
		data[idx + 1] = (sample_val >> 8) & 0xFF
		
	return _make_wav(data, sample_rate)

func _synth_arpeggio(notes: Array, note_duration: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_duration: float = note_duration * notes.size()
	var num_samples: int = int(sample_rate * total_duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var note_idx: int = min(int((float(i) / float(sample_rate)) / note_duration), notes.size() - 1)
		var freq: float = float(notes[note_idx])
		var local_t: float = fmod(float(i) / float(sample_rate), note_duration) / note_duration
		var env: float = 1.0 - local_t
		var phase: float = float(i) * freq / float(sample_rate) * TAU
		var sample_val: int = int(sin(phase) * 18000.0 * env)
		sample_val = clampi(sample_val, -32768, 32767)
		
		var idx: int = i * 2
		data[idx] = sample_val & 0xFF
		data[idx + 1] = (sample_val >> 8) & 0xFF
		
	return _make_wav(data, sample_rate)

func _make_wav(data: PackedByteArray, mix_rate: int) -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = mix_rate
	wav.data = data
	return wav
