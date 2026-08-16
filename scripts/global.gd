extends Node

# Enums
enum PaddleType { NORMAL, SHORT, LONG, STICKY, SHIELDED, LASER }
enum BallType { NORMAL, FAST, FIRE, ICE, ELECTRIC }
enum BrickType {
	RED, ORANGE, YELLOW, GREEN, BLUE, PURPLE,
	DAMAGE_1, DAMAGE_2, DAMAGE_3,
	ARMORED_DARK, ARMORED_GOLD, UNBREAKABLE,
	EXPLOSIVE, POWERUP, MOVING, PORTAL_EXIT
}
enum PowerupType {
	MULTIBALL, EXTRA_LIFE, EXPAND, SHRINK,
	STICKY, LASER, FIREBALL, SLOW, SHIELD, SCORE_X
}
enum HazardType { SPIKES, MINE, BUMPER, ELECTRIC, TURRET }

# Signals
signal score_changed(new_score)
signal high_score_changed(new_high_score)
signal lives_changed(new_lives)
signal combo_changed(new_combo, multiplier)
signal level_completed()
signal game_over()
signal powerup_activated(type_idx, duration)
signal powerup_deactivated(type_idx)
signal shield_state_changed(active)

# Game State
const GAME_VERSION: String = "0.2.0"
var score: int = 0
var high_score: int = 0
var lives: int = 3
var current_level: int = 1
var max_unlocked_level: int = 1
var combo_count: int = 0
var combo_multiplier: float = 1.0

var sound_enabled: bool = true
var music_enabled: bool = true

# Active powerups and remaining duration dictionary
var active_powerups: Dictionary = {} # PowerupType -> float (time remaining)
var bottom_shield_active: bool = false
var score_multiplier_active: bool = false

# Constant bounds for gameplay arena
const PLAYFIELD_LEFT: float = 60.0
const PLAYFIELD_RIGHT: float = 1220.0
const PLAYFIELD_TOP: float = 70.0
const PLAYFIELD_BOTTOM: float = 690.0

func _ready() -> void:
	load_high_score()

func _process(delta: float) -> void:
	# Process active powerup timers
	var expired: Array = []
	for ptype in active_powerups.keys():
		active_powerups[ptype] -= delta
		if active_powerups[ptype] <= 0:
			expired.append(ptype)
			
	for ptype in expired:
		deactivate_powerup(ptype)

func start_new_game(level_idx: int = 1) -> void:
	score = 0
	lives = 3
	combo_count = 0
	combo_multiplier = 1.0
	current_level = level_idx
	clear_all_powerups()
	score_changed.emit(score)
	lives_changed.emit(lives)
	combo_changed.emit(combo_count, combo_multiplier)

func add_score(amount: int) -> void:
	var final_amount: int = int(amount * combo_multiplier)
	if score_multiplier_active:
		final_amount *= 2
	score += final_amount
	if score > high_score:
		high_score = score
		save_high_score()
		high_score_changed.emit(high_score)
	score_changed.emit(score)

func increment_combo() -> void:
	combo_count += 1
	if combo_count >= 15:
		combo_multiplier = 3.0
	elif combo_count >= 10:
		combo_multiplier = 2.5
	elif combo_count >= 5:
		combo_multiplier = 2.0
	elif combo_count >= 3:
		combo_multiplier = 1.5
	else:
		combo_multiplier = 1.0
	combo_changed.emit(combo_count, combo_multiplier)

func reset_combo() -> void:
	combo_count = 0
	combo_multiplier = 1.0
	combo_changed.emit(combo_count, combo_multiplier)

func lose_life() -> void:
	lives -= 1
	reset_combo()
	lives_changed.emit(lives)
	if lives <= 0:
		game_over.emit()

func add_life() -> void:
	lives += 1
	lives_changed.emit(lives)

func activate_powerup(ptype: int, duration: float = 12.0) -> void:
	match ptype:
		PowerupType.EXTRA_LIFE:
			add_life()
			return
		PowerupType.MULTIBALL:
			# Handled in game scene to spawn extra balls
			powerup_activated.emit(ptype, 0.0)
			return
		PowerupType.SHIELD:
			bottom_shield_active = true
			shield_state_changed.emit(true)
		PowerupType.SCORE_X:
			score_multiplier_active = true

	active_powerups[ptype] = duration
	powerup_activated.emit(ptype, duration)

func deactivate_powerup(ptype: int) -> void:
	active_powerups.erase(ptype)
	match ptype:
		PowerupType.SHIELD:
			bottom_shield_active = false
			shield_state_changed.emit(false)
		PowerupType.SCORE_X:
			score_multiplier_active = false
	powerup_deactivated.emit(ptype)

func is_powerup_active(ptype: int) -> bool:
	return active_powerups.has(ptype)

func clear_all_powerups() -> void:
	var keys: Array = active_powerups.keys().duplicate()
	for k in keys:
		deactivate_powerup(k)
	bottom_shield_active = false
	score_multiplier_active = false
	shield_state_changed.emit(false)

func unlock_next_level() -> void:
	if current_level + 1 > max_unlocked_level:
		max_unlocked_level = min(current_level + 1, 5)

func save_high_score() -> void:
	var file = FileAccess.open("user://highscore.dat", FileAccess.WRITE)
	if file:
		file.store_32(high_score)
		file.store_32(max_unlocked_level)

func load_high_score() -> void:
	if FileAccess.file_exists("user://highscore.dat"):
		var file = FileAccess.open("user://highscore.dat", FileAccess.READ)
		if file:
			high_score = file.get_32()
			max_unlocked_level = max(1, file.get_32())
