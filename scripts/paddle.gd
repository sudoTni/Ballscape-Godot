extends CharacterBody2D

@export var move_speed: float = 850.0
var paddle_type: int = Global.PaddleType.NORMAL
var paddle_width: float = 160.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var laser_cooldown_timer: Timer = $LaserTimer

var laser_bolt_scene = preload("res://scenes/laser_bolt.tscn")
var can_fire_laser: bool = true

const PADDLE_TEXTURES: Dictionary = {
	Global.PaddleType.NORMAL: "res://assets/sprites/paddle_normal.tres",
	Global.PaddleType.SHORT: "res://assets/sprites/paddle_short.tres",
	Global.PaddleType.LONG: "res://assets/sprites/paddle_long.tres",
	Global.PaddleType.STICKY: "res://assets/sprites/paddle_sticky.tres",
	Global.PaddleType.SHIELDED: "res://assets/sprites/paddle_shielded.tres",
	Global.PaddleType.LASER: "res://assets/sprites/paddle_laser.tres"
}

const PADDLE_WIDTHS: Dictionary = {
	Global.PaddleType.NORMAL: 160.0,
	Global.PaddleType.SHORT: 110.0,
	Global.PaddleType.LONG: 230.0,
	Global.PaddleType.STICKY: 175.0,
	Global.PaddleType.SHIELDED: 170.0,
	Global.PaddleType.LASER: 160.0
}

func _ready() -> void:
	add_to_group("paddle")
	Global.powerup_activated.connect(_on_powerup_activated)
	Global.powerup_deactivated.connect(_on_powerup_deactivated)
	laser_cooldown_timer.timeout.connect(func(): can_fire_laser = true)
	update_paddle_type(Global.PaddleType.NORMAL)

func update_paddle_type(ptype: int) -> void:
	paddle_type = ptype
	if PADDLE_TEXTURES.has(paddle_type):
		sprite.texture = load(PADDLE_TEXTURES[paddle_type])
		
	if PADDLE_WIDTHS.has(paddle_type):
		paddle_width = PADDLE_WIDTHS[paddle_type]
		var shape = RectangleShape2D.new()
		shape.size = Vector2(paddle_width, 40.0)
		collision_shape.shape = shape

func get_paddle_width() -> float:
	return paddle_width

func _physics_process(delta: float) -> void:
	# Check current active powerups to determine paddle state
	_update_active_powerup_type()
	
	var target_x: float = position.x
	var mouse_pos = get_global_mouse_position()
	
	# Mouse control priority if mouse is moving inside window
	if Input.get_last_mouse_velocity().length() > 10.0 or true:
		target_x = mouse_pos.x
		
	# Keyboard override
	var dir = Input.get_axis("ui_left", "ui_right")
	if dir != 0:
		target_x = position.x + dir * move_speed * delta

	# Smoothly interpolate paddle position
	position.x = lerpf(position.x, target_x, 25.0 * delta)
	
	# Clamp position within playfield
	var half_w = paddle_width * 0.5
	position.x = clampf(position.x, Global.PLAYFIELD_LEFT + half_w, Global.PLAYFIELD_RIGHT - half_w)
	position.y = 660.0 # Fixed paddle vertical plane

	# Fire laser if laser paddle active
	if paddle_type == Global.PaddleType.LASER:
		if (Input.is_action_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and can_fire_laser:
			_fire_lasers()

func _fire_lasers() -> void:
	can_fire_laser = false
	laser_cooldown_timer.start(0.22)
	AudioManager.play_sfx("laser")
	
	var left_offset = Vector2(-paddle_width * 0.4, -20.0)
	var right_offset = Vector2(paddle_width * 0.4, -20.0)
	
	_spawn_laser_at(global_position + left_offset)
	_spawn_laser_at(global_position + right_offset)

func _spawn_laser_at(pos: Vector2) -> void:
	var laser = laser_bolt_scene.instantiate()
	laser.global_position = pos
	get_parent().add_child(laser)

func _update_active_powerup_type() -> void:
	if Global.is_powerup_active(Global.PowerupType.LASER):
		if paddle_type != Global.PaddleType.LASER:
			update_paddle_type(Global.PaddleType.LASER)
	elif Global.is_powerup_active(Global.PowerupType.EXPAND):
		if paddle_type != Global.PaddleType.LONG:
			update_paddle_type(Global.PaddleType.LONG)
	elif Global.is_powerup_active(Global.PowerupType.SHRINK):
		if paddle_type != Global.PaddleType.SHORT:
			update_paddle_type(Global.PaddleType.SHORT)
	elif Global.is_powerup_active(Global.PowerupType.STICKY):
		if paddle_type != Global.PaddleType.STICKY:
			update_paddle_type(Global.PaddleType.STICKY)
	elif Global.is_powerup_active(Global.PowerupType.SHIELD):
		if paddle_type != Global.PaddleType.SHIELDED:
			update_paddle_type(Global.PaddleType.SHIELDED)
	else:
		if paddle_type != Global.PaddleType.NORMAL:
			update_paddle_type(Global.PaddleType.NORMAL)

func _on_powerup_activated(_ptype: int, _dur: float) -> void:
	_update_active_powerup_type()

func _on_powerup_deactivated(_ptype: int) -> void:
	_update_active_powerup_type()

func on_ball_bounce() -> void:
	# Quick bounce scale pulse
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(0.9, 0.7), 0.05)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
