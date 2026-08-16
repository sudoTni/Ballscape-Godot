extends Area2D

signal boss_destroyed()

@export var max_hp: int = 100
var hp: int = 100
var phase: int = 1
var shoot_timer: float = 0.0
var move_dir: float = 1.0
var move_speed: float = 120.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hp_bar: TextureProgressBar = $HPBar

func _ready() -> void:
	add_to_group("regular_bricks") # Allows ball collision
	add_to_group("boss")
	hp = max_hp
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	# Horizontal sliding
	position.x += move_speed * move_dir * delta
	if position.x > 950.0:
		move_dir = -1.0
	elif position.x < 330.0:
		move_dir = 1.0
		
	# Shooting logic based on phase
	shoot_timer += delta
	var cooldown = 2.8 if phase == 1 else (2.0 if phase == 2 else 1.2)
	if shoot_timer >= cooldown:
		shoot_timer = 0.0
		_fire_boss_attack()

func _fire_boss_attack() -> void:
	AudioManager.play_sfx("laser")
	var parent = get_parent()
	if not parent: return
	
	if phase == 1:
		_spawn_boss_laser(Vector2(-60, 40), Vector2(0, 500))
		_spawn_boss_laser(Vector2(60, 40), Vector2(0, 500))
	elif phase == 2:
		_spawn_boss_laser(Vector2(-60, 40), Vector2(-150, 450))
		_spawn_boss_laser(Vector2(0, 50), Vector2(0, 500))
		_spawn_boss_laser(Vector2(60, 40), Vector2(150, 450))
	else:
		# Enraged 5-way spread
		for angle in [-0.4, -0.2, 0.0, 0.2, 0.4]:
			var dir = Vector2.DOWN.rotated(angle) * 520.0
			_spawn_boss_laser(Vector2.ZERO, dir)

func _spawn_boss_laser(offset: Vector2, vel: Vector2) -> void:
	var parent = get_parent()
	if not parent: return
	var bolt = preload("res://scenes/laser_bolt.tscn").instantiate()
	bolt.global_position = global_position + offset
	bolt.speed = -vel.y # downward velocity
	parent.add_child(bolt)

func on_ball_hit(ball: Node2D, collision: KinematicCollision2D) -> bool:
	take_damage(2)
	return false

func take_damage(amount: int) -> void:
	hp -= amount
	AudioManager.play_sfx("brick_hit")
	
	# Flash feedback
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(3.0, 0.3, 0.3, 1.0), 0.05)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.08)
	
	# Camera shake on hit
	var parent = get_parent()
	if parent and parent.has_method("shake_camera"):
		parent.shake_camera(0.25)
		
	# Check phase transitions
	if hp <= 35 and phase < 3:
		phase = 3
		move_speed = 220.0
		sprite.modulate = Color(1.0, 0.3, 0.3, 1.0)
	elif hp <= 70 and phase < 2:
		phase = 2
		move_speed = 170.0

	if hp <= 0:
		_defeat_boss()

func _defeat_boss() -> void:
	Global.add_score(10000)
	AudioManager.play_sfx("explosion")
	
	var parent = get_parent()
	if parent and parent.has_method("spawn_fx"):
		parent.spawn_fx("res://assets/sprites/fx_explosion_large.tres", global_position, 0.8, 1.0, 3.5)
		parent.spawn_fx("res://assets/sprites/fx_shockwave.tres", global_position, 0.6, 0.8, 4.0)
		if parent.has_method("shake_camera"):
			parent.shake_camera(0.8)

	boss_destroyed.emit()
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("balls"):
		take_damage(2)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("laser_bolts"):
		take_damage(1)
		area.queue_free()
