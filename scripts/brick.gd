extends StaticBody2D

signal brick_destroyed(brick_node)

@export var brick_type: int = Global.BrickType.RED
var max_hp: int = 1
var hp: int = 1
var score_value: int = 100
var is_moving: bool = false
var move_dir: float = 1.0
var move_speed: float = 80.0
var portal_target: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const BRICK_TEXTURES: Dictionary = {
	Global.BrickType.RED: "res://assets/sprites/brick_red.tres",
	Global.BrickType.ORANGE: "res://assets/sprites/brick_orange.tres",
	Global.BrickType.YELLOW: "res://assets/sprites/brick_yellow.tres",
	Global.BrickType.GREEN: "res://assets/sprites/brick_green.tres",
	Global.BrickType.BLUE: "res://assets/sprites/brick_blue.tres",
	Global.BrickType.PURPLE: "res://assets/sprites/brick_purple.tres",
	Global.BrickType.DAMAGE_1: "res://assets/sprites/brick_damage_1.tres",
	Global.BrickType.DAMAGE_2: "res://assets/sprites/brick_damage_2.tres",
	Global.BrickType.DAMAGE_3: "res://assets/sprites/brick_damage_3.tres",
	Global.BrickType.ARMORED_DARK: "res://assets/sprites/brick_armored_dark.tres",
	Global.BrickType.ARMORED_GOLD: "res://assets/sprites/brick_armored_gold.tres",
	Global.BrickType.UNBREAKABLE: "res://assets/sprites/brick_unbreakable.tres",
	Global.BrickType.EXPLOSIVE: "res://assets/sprites/brick_explosive.tres",
	Global.BrickType.POWERUP: "res://assets/sprites/brick_powerup.tres",
	Global.BrickType.MOVING: "res://assets/sprites/brick_moving.tres",
	Global.BrickType.PORTAL_EXIT: "res://assets/sprites/brick_portal_exit.tres"
}

func setup(btype: int) -> void:
	brick_type = btype

func _ready() -> void:
	add_to_group("bricks")
	_init_properties()

func _init_properties() -> void:
	match brick_type:
		Global.BrickType.RED: score_value = 100; max_hp = 1
		Global.BrickType.ORANGE: score_value = 150; max_hp = 1
		Global.BrickType.YELLOW: score_value = 200; max_hp = 1
		Global.BrickType.GREEN: score_value = 250; max_hp = 1
		Global.BrickType.BLUE: score_value = 300; max_hp = 1
		Global.BrickType.PURPLE: score_value = 400; max_hp = 1
		Global.BrickType.DAMAGE_1: score_value = 500; max_hp = 3
		Global.BrickType.DAMAGE_2: score_value = 350; max_hp = 2
		Global.BrickType.DAMAGE_3: score_value = 200; max_hp = 1
		Global.BrickType.ARMORED_DARK: score_value = 600; max_hp = 3
		Global.BrickType.ARMORED_GOLD: score_value = 1000; max_hp = 5
		Global.BrickType.UNBREAKABLE: score_value = 0; max_hp = 99999
		Global.BrickType.EXPLOSIVE: score_value = 300; max_hp = 1
		Global.BrickType.POWERUP: score_value = 250; max_hp = 1
		Global.BrickType.MOVING: score_value = 300; max_hp = 1; is_moving = true
		Global.BrickType.PORTAL_EXIT: score_value = 200; max_hp = 1
		
	hp = max_hp
	_update_texture()

	# Mark regular vs indestructible
	if brick_type != Global.BrickType.UNBREAKABLE:
		add_to_group("regular_bricks")

func _update_texture() -> void:
	var tex_key = brick_type
	if brick_type == Global.BrickType.DAMAGE_3 or brick_type == Global.BrickType.DAMAGE_2 or brick_type == Global.BrickType.DAMAGE_1:
		if hp == 3: tex_key = Global.BrickType.DAMAGE_1
		elif hp == 2: tex_key = Global.BrickType.DAMAGE_2
		elif hp == 1: tex_key = Global.BrickType.DAMAGE_3
	elif brick_type == Global.BrickType.ARMORED_DARK:
		if hp == 3: tex_key = Global.BrickType.ARMORED_DARK
		elif hp == 2: tex_key = Global.BrickType.DAMAGE_1
		elif hp == 1: tex_key = Global.BrickType.DAMAGE_3
	elif brick_type == Global.BrickType.ARMORED_GOLD:
		if hp >= 4: tex_key = Global.BrickType.ARMORED_GOLD
		elif hp == 3: tex_key = Global.BrickType.DAMAGE_1
		elif hp == 2: tex_key = Global.BrickType.DAMAGE_2
		elif hp == 1: tex_key = Global.BrickType.DAMAGE_3
		
	if BRICK_TEXTURES.has(tex_key):
		sprite.texture = load(BRICK_TEXTURES[tex_key])

func _process(delta: float) -> void:
	if is_moving:
		position.x += move_speed * move_dir * delta
		if position.x > Global.PLAYFIELD_RIGHT - 80.0:
			move_dir = -1.0
		elif position.x < Global.PLAYFIELD_LEFT + 80.0:
			move_dir = 1.0

func on_ball_hit(ball: Node2D, collision: KinematicCollision2D) -> bool:
	if brick_type == Global.BrickType.UNBREAKABLE:
		AudioManager.play_sfx("bounce")
		return false
		
	if brick_type == Global.BrickType.PORTAL_EXIT and is_instance_valid(portal_target):
		_teleport_ball(ball)
		return false
		
	take_damage(1)
	return false

func take_damage(amount: int) -> void:
	if brick_type == Global.BrickType.UNBREAKABLE:
		return
		
	hp -= amount
	
	# Impact feedback animation
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(2.0, 2.0, 2.0, 1.0), 0.05)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.08)
	
	if hp <= 0:
		_destroy()
	else:
		AudioManager.play_sfx("brick_hit")
		_update_texture()
		_spawn_hit_particles()

func _teleport_ball(ball: Node2D) -> void:
	AudioManager.play_sfx("laser")
	ball.global_position = portal_target.global_position + Vector2(0, 45)
	var parent = get_parent()
	if parent and parent.has_method("spawn_fx"):
		parent.spawn_fx("res://assets/sprites/fx_portal_swirl.tres", global_position, 0.4, 0.5, 1.2, 5.0)
		parent.spawn_fx("res://assets/sprites/fx_portal_swirl.tres", portal_target.global_position, 0.4, 0.5, 1.2, 5.0)

func _destroy() -> void:
	Global.add_score(score_value)
	AudioManager.play_sfx("brick_destroy")
	
	# Spawn particle debris FX
	var parent = get_parent()
	if parent and parent.has_method("spawn_fx"):
		parent.spawn_fx("res://assets/sprites/fx_debris_shards.tres", global_position, 0.35, 0.6, 1.3)
		
	# Explosive brick chain reaction
	if brick_type == Global.BrickType.EXPLOSIVE:
		_trigger_explosion()
		
	# Powerup drop chance
	if brick_type == Global.BrickType.POWERUP or randf() < 0.18:
		_drop_powerup()
		
	brick_destroyed.emit(self)
	queue_free()

func _trigger_explosion() -> void:
	AudioManager.play_sfx("explosion")
	var parent = get_parent()
	if parent and parent.has_method("spawn_fx"):
		parent.spawn_fx("res://assets/sprites/fx_explosion_large.tres", global_position, 0.6, 0.8, 2.2)
		parent.spawn_fx("res://assets/sprites/fx_shockwave.tres", global_position, 0.5, 0.5, 2.5)

	# Destroy adjacent bricks within 130px radius
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 130.0
	query.shape = circle
	query.transform = global_transform
	query.collision_mask = 2 # Bricks layer
	
	var results = space_state.intersect_shape(query)
	for res in results:
		var col = res["collider"]
		if col != self and col.has_method("take_damage"):
			col.take_damage(2)

func _drop_powerup() -> void:
	var parent = get_parent()
	if parent and parent.has_method("spawn_powerup"):
		parent.spawn_powerup(global_position)

func _spawn_hit_particles() -> void:
	var parent = get_parent()
	if parent and parent.has_method("spawn_fx"):
		parent.spawn_fx("res://assets/sprites/fx_impact_spark.tres", global_position, 0.25, 0.5, 0.9)
