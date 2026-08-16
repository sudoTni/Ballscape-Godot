extends Control

@onready var level_grid: HBoxContainer = $MarginContainer/VBoxContainer/LevelSelectContainer/HBoxContainer
@onready var high_score_label: Label = $MarginContainer/VBoxContainer/HighScoreLabel
@onready var how_to_play_modal: Control = $HowToPlayModal
@onready var sound_btn: TextureButton = $MarginContainer/VBoxContainer/BottomBar/SoundBtn
@onready var version_label: Label = $VersionLabel

var lock_tex = preload("res://assets/sprites/ui_lock.tres")

func _ready() -> void:
	Global.load_high_score()
	high_score_label.text = "HIGH SCORE: %06d" % Global.high_score
	if version_label:
		version_label.text = "v" + Global.GAME_VERSION
	
	$MarginContainer/VBoxContainer/BottomBar/HowToPlayBtn.pressed.connect(_on_how_to_play_pressed)
	$MarginContainer/VBoxContainer/BottomBar/LevelMakerBtn.pressed.connect(_on_level_maker_pressed)
	$HowToPlayModal/Panel/CloseBtn.pressed.connect(_on_close_modal_pressed)
	sound_btn.pressed.connect(_on_sound_pressed)

	_build_level_buttons()

func _build_level_buttons() -> void:
	for child in level_grid.get_children():
		child.queue_free()

	for i in range(1, 7):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(130, 130)
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		var unlocked = (i <= Global.max_unlocked_level or i == 1)
		if unlocked:
			if i == 6:
				btn.text = "👑 BOSS"
				btn.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
			else:
				btn.text = "LEVEL %d" % i
			btn.add_theme_font_size_override("font_size", 20)
			btn.pressed.connect(func(): _start_level(i))
		else:
			btn.disabled = true
			var tr = TextureRect.new()
			tr.texture = lock_tex
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr.custom_minimum_size = Vector2(45, 45)
			tr.anchors_preset = Control.PRESET_CENTER
			tr.position = Vector2(42, 42)
			btn.add_child(tr)

		level_grid.add_child(btn)

func _start_level(level_idx: int) -> void:
	AudioManager.play_sfx("click")
	Global.current_level = level_idx
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_level_maker_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/level_editor.tscn")

func _on_how_to_play_pressed() -> void:
	AudioManager.play_sfx("click")
	how_to_play_modal.visible = true

func _on_close_modal_pressed() -> void:
	AudioManager.play_sfx("click")
	how_to_play_modal.visible = false

func _on_sound_pressed() -> void:
	Global.sound_enabled = not Global.sound_enabled
	AudioManager.play_sfx("click")
	sound_btn.modulate = Color.WHITE if Global.sound_enabled else Color(0.5, 0.5, 0.5, 0.7)
