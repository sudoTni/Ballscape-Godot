extends CanvasLayer

@onready var score_label: Label = $TopBar/MarginContainer/HBoxContainer/ScoreContainer/ScoreLabel
@onready var high_score_label: Label = $TopBar/MarginContainer/HBoxContainer/ScoreContainer/HighScoreLabel
@onready var combo_label: Label = $TopBar/MarginContainer/HBoxContainer/ComboContainer/ComboLabel
@onready var lives_container: HBoxContainer = $TopBar/MarginContainer/HBoxContainer/LivesContainer
@onready var level_label: Label = $TopBar/MarginContainer/HBoxContainer/LevelLabel
@onready var shield_indicator: TextureRect = $TopBar/MarginContainer/HBoxContainer/ShieldIndicator

@onready var pause_overlay: Control = $PauseOverlay
@onready var game_over_overlay: Control = $GameOverOverlay
@onready var level_clear_overlay: Control = $LevelClearOverlay

@onready var pause_btn: TextureButton = $TopBar/MarginContainer/HBoxContainer/PauseBtn
@onready var sound_btn: TextureButton = $TopBar/MarginContainer/HBoxContainer/SoundBtn

var life_icon_tex = preload("res://assets/sprites/ui_life.tres")

func _ready() -> void:
	Global.score_changed.connect(_on_score_changed)
	Global.high_score_changed.connect(_on_high_score_changed)
	Global.lives_changed.connect(_on_lives_changed)
	Global.combo_changed.connect(_on_combo_changed)
	Global.shield_state_changed.connect(_on_shield_changed)
	
	pause_btn.pressed.connect(_on_pause_pressed)
	sound_btn.pressed.connect(_on_sound_pressed)

	$PauseOverlay/Panel/VBoxContainer/ResumeBtn.pressed.connect(_on_resume_pressed)
	$PauseOverlay/Panel/VBoxContainer/RestartBtn.pressed.connect(_on_restart_pressed)
	$PauseOverlay/Panel/VBoxContainer/MenuBtn.pressed.connect(_on_menu_pressed)

	$GameOverOverlay/Panel/VBoxContainer/RestartBtn.pressed.connect(_on_restart_pressed)
	$GameOverOverlay/Panel/VBoxContainer/MenuBtn.pressed.connect(_on_menu_pressed)

	$LevelClearOverlay/Panel/VBoxContainer/NextLevelBtn.pressed.connect(_on_next_level_pressed)
	$LevelClearOverlay/Panel/VBoxContainer/MenuBtn.pressed.connect(_on_menu_pressed)

	update_hud()

func update_hud() -> void:
	_on_score_changed(Global.score)
	_on_high_score_changed(Global.high_score)
	_on_lives_changed(Global.lives)
	_on_combo_changed(Global.combo_count, Global.combo_multiplier)
	level_label.text = "LEVEL " + str(Global.current_level)

func _on_score_changed(new_score: int) -> void:
	score_label.text = "SCORE: %06d" % new_score

func _on_high_score_changed(new_high: int) -> void:
	high_score_label.text = "HIGH: %06d" % new_high

func _on_lives_changed(new_lives: int) -> void:
	for child in lives_container.get_children():
		child.queue_free()
		
	for i in range(max(0, new_lives)):
		var tr = TextureRect.new()
		tr.texture = life_icon_tex
		tr.custom_minimum_size = Vector2(36, 36)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		lives_container.add_child(tr)

func _on_combo_changed(count: int, mult: float) -> void:
	if count > 1:
		combo_label.text = "COMBO x%.1f (%d)" % [mult, count]
		combo_label.visible = true
		var tween = create_tween()
		tween.tween_property(combo_label, "scale", Vector2(1.2, 1.2), 0.05)
		tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.08)
	else:
		combo_label.visible = false

func _on_shield_changed(active: bool) -> void:
	shield_indicator.visible = active

func _on_pause_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().paused = true
	pause_overlay.visible = true

func _on_sound_pressed() -> void:
	Global.sound_enabled = not Global.sound_enabled
	AudioManager.play_sfx("click")
	sound_btn.modulate = Color.WHITE if Global.sound_enabled else Color(0.5, 0.5, 0.5, 0.7)

func _on_resume_pressed() -> void:
	AudioManager.play_sfx("click")
	pause_overlay.visible = false
	get_tree().paused = false

func _on_restart_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_next_level_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().paused = false
	Global.current_level = min(Global.current_level + 1, 5)
	get_tree().reload_current_scene()

func show_game_over() -> void:
	AudioManager.play_sfx("lose_life")
	$GameOverOverlay/Panel/VBoxContainer/FinalScoreLabel.text = "FINAL SCORE: %d" % Global.score
	gameOverOverlayShow()

func gameOverOverlayShow() -> void:
	game_over_overlay.visible = true

func show_level_clear() -> void:
	AudioManager.play_sfx("level_clear")
	$LevelClearOverlay/Panel/VBoxContainer/LevelScoreLabel.text = "LEVEL %d CLEARED!\nSCORE: %d" % [Global.current_level, Global.score]
	level_clear_overlay.visible = true
