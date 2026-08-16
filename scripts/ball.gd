extends CharacterBody2D

signal ball_lost(ball_node)

@export var base_speed: float = 480.0
var ball_type: int = Global.BallType.NORMAL
var current_speed: float = 480.0

var is_stuck_to_paddle: bool = true
var paddle_ref: Node2D = null
var stuck_offset_x: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var trail_sprite: Sprite2D = $TrailSprite

const BALL_TEXTURES: Dictionary = {
	Global.BallType.NORMAL: "res://assets/sprites/ball_normal.tres",
	Global.BallType.FAST: "res://assets/sprites/ball_fast.tres",
	Global.BallType.FIRE: "res://assets/sprites/ball_fire.tres",
	Global.BallType.ICE: "res://assets/sprites/ball_ice.tres",
	Global.BallType.ELECTRIC: "res://assets/sprites/ball_electric.tres"
}

func _ready() -> void:
	add_to_group("balls")
	update_type(ball_type)

func update_type(btype: int) -> void:
	ball_type = btype
	if BALL_TEXTURES.has(ball_type):
		sprite.texture = load(BALL_TEXTURES[ball_type])
		
	match ball_type:
		Global.BallType.FAST:
			current_speed = base_speed * 1.3
			trail_sprite.visible = true
		Global.BallType.ICE:
			current_speed = base_speed * 0.85
			trail_sprite.visible = false
		Global.BallType.FIRE:
			current_speed = base_speed * 1.15
			trail_sprite.visible = true
		_:
			current_speed = base_speed
			trail_sprite.visible = false

func launch(initial_dir: Vector2 = Vector2(0.3, -0.9).normalized()) -> void:
	is_stuck_to_paddle = false
	velocity = initial_dir * current_speed

func _physics_process(delta: float) -> void:
	if is_stuck_to_paddle:
		if is_instance_valid(paddle_ref):
			position.x = paddle_ref.position.x + stuck_offset_x
			position.y = paddle_ref.position.y - 30.0
		if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			launch()
		return

	# Speed modifications from global powerups
	var target_speed = current_speed
	if Global.is_powerup_active(Global.PowerupType.SLOW):
		target_speed *= 0.7
	if Global.is_powerup_active(Global.PowerupType.FIREBALL):
		update_type(Global.BallType.FIRE)

	var motion = velocity.normalized() * target_speed * delta
	var collision = move_and_collide(motion)
	
	if collision:
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		
		# Play bounce SFX
		AudioManager.play_sfx("bounce")
		
		# Spawn bounce flash FX
		var parent = get_parent()
		if parent and parent.has_method("spawn_fx"):
			parent.spawn_fx("res://assets/sprites/fx_bounce_flash.tres", collision.get_position(), 0.2, 0.4, 0.7)

		if collider.is_in_group("paddle"):
			# Deflect ball based on hit position relative to paddle center
			var p_center = collider.global_position.x
			var p_width = collider.get_paddle_width()
			var hit_factor = (global_position.x - p_center) / (p_width * 0.5)
			hit_factor = clampf(hit_factor, -0.85, 0.85)
			
			if Global.is_powerup_active(Global.PowerupType.STICKY) or collider.paddle_type == Global.PaddleType.STICKY:
				is_stuck_to_paddle = true
				paddle_ref = collider
				stuck_offset_x = global_position.x - p_center
				velocity = Vector2.ZERO
			else:
				# Bounce upwards with angle spread
				var angle = hit_factor * (PI / 3.0)
				velocity = Vector2.UP.rotated(angle) * target_speed
				Global.increment_combo()

		elif collider.has_method("on_ball_hit"):
			# Brick or Hazard hit
			var destroy_ball = collider.on_ball_hit(self, collision)
			if destroy_ball:
				queue_free()
				return
			
			# Fireball pierces regular bricks without bouncing back
			if ball_type == Global.BallType.FIRE and collider.is_in_group("regular_bricks"):
				pass # Keep going straight through
			else:
				velocity = velocity.bounce(normal)

		else:
			# Wall or border bounce
			velocity = velocity.bounce(normal)

	# Update trail rotation/position
	if trail_sprite.visible:
		trail_sprite.global_position = global_position - velocity.normalized() * 18.0
		trail_sprite.rotation = velocity.angle()

	# Check playfield boundaries bottom
	if position.y > Global.PLAYFIELD_BOTTOM + 30.0:
		if Global.bottom_shield_active:
			velocity.y = -abs(velocity.y)
			position.y = Global.PLAYFIELD_BOTTOM - 10.0
			AudioManager.play_sfx("bounce")
		else:
			ball_lost.emit(self)
			queue_free()
