extends Area2D

@export var hazard_type: int = Global.HazardType.SPIKES
var float_offset: float = 0.0
var shoot_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D

const HAZARD_TEXTURES: Dictionary = {
	Global.HazardType.SPIKES: "res://assets/sprites/hazard_spikes.tres",
	Global.HazardType.MINE: "res://assets/sprites/hazard_mine.tres",
	Global.HazardType.BUMPER: "res://assets/sprites/hazard_bumper.tres",
	Global.HazardType.ELECTRIC: "res://assets/sprites/hazard_electric.tres",
	Global.HazardType.TURRET: "res://assets/sprites/hazard_turret.tres"
}

func setup(htype: int) -> void:
	hazard_type = htype

func _ready() -> void:
	add_to_group("hazards")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	if HAZARD_TEXTURES.has(hazard_type):
		sprite.texture = load(HAZARD_TEXTURES[hazard_type])
		
	float_offset = randf() * TAU

func _process(delta: float) -> void:
	# Gently float up and down
	position.y += sin(Time.get_ticks_msec() * 0.003 + float_offset) * 0.4
	
	# Turret shooting behavior
	if hazard_type == Global.HazardType.TURRET:
		shoot_timer += delta
		if shoot_timer >= 3.5:
			shoot_timer = 0.0
			_turret_shoot()

func _turret_shoot() -> void:
	AudioManager.play_sfx("laser")
	var bolt = preload("res://scenes/laser_bolt.tscn").instantiate()
	bolt.speed = -450.0 # Moves downwards toward player!
	bolt.global_position = global_position + Vector2(0, 30)
	get_parent().add_child(bolt)

func on_ball_hit(ball: Node2D, collision: KinematicCollision2D) -> bool:
	match hazard_type:
		Global.HazardType.SPIKES:
			AudioManager.play_sfx("lose_life")
			_spawn_fx("res://assets/sprites/fx_explosion_small.tres")
			return true # Destroy ball
		Global.HazardType.MINE:
			AudioManager.play_sfx("explosion")
			_spawn_fx("res://assets/sprites/fx_explosion_large.tres")
			queue_free()
			return true # Destroy ball & mine
		Global.HazardType.BUMPER:
			AudioManager.play_sfx("bounce")
			_spawn_fx("res://assets/sprites/fx_shockwave.tres")
			var tween = create_tween()
			tween.tween_property(sprite, "scale", Vector2(0.9, 0.9), 0.05)
			tween.tween_property(sprite, "scale", Vector2(0.6, 0.6), 0.1)
			return false
		Global.HazardType.ELECTRIC:
			AudioManager.play_sfx("brick_hit")
			_spawn_fx("res://assets/sprites/fx_impact_spark.tres")
			return false
	return false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("paddle") and hazard_type == Global.HazardType.MINE:
		AudioManager.play_sfx("explosion")
		Global.lose_life()
		_spawn_fx("res://assets/sprites/fx_explosion_large.tres")
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("laser_bolts") and hazard_type != Global.HazardType.SPIKES:
		_spawn_fx("res://assets/sprites/fx_impact_spark.tres")
		queue_free()

func _spawn_fx(tex_path: String) -> void:
	var parent = get_parent()
	if parent and parent.has_method("spawn_fx"):
		parent.spawn_fx(tex_path, global_position, 0.4, 0.6, 1.3)
