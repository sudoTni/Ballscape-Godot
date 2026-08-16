extends Area2D

@export var fall_speed: float = 160.0
var powerup_type: int = Global.PowerupType.MULTIBALL

@onready var sprite: Sprite2D = $Sprite2D
@onready var aura_sprite: Sprite2D = $AuraSprite

const POWERUP_TEXTURES: Dictionary = {
	Global.PowerupType.MULTIBALL: "res://assets/sprites/powerup_multiball.tres",
	Global.PowerupType.EXTRA_LIFE: "res://assets/sprites/powerup_extra_life.tres",
	Global.PowerupType.EXPAND: "res://assets/sprites/powerup_expand.tres",
	Global.PowerupType.SHRINK: "res://assets/sprites/powerup_shrink.tres",
	Global.PowerupType.STICKY: "res://assets/sprites/powerup_sticky.tres",
	Global.PowerupType.LASER: "res://assets/sprites/powerup_laser.tres",
	Global.PowerupType.FIREBALL: "res://assets/sprites/powerup_fireball.tres",
	Global.PowerupType.SLOW: "res://assets/sprites/powerup_slow.tres",
	Global.PowerupType.SHIELD: "res://assets/sprites/powerup_shield.tres",
	Global.PowerupType.SCORE_X: "res://assets/sprites/powerup_score_x.tres"
}

func setup(ptype: int) -> void:
	powerup_type = ptype

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	if POWERUP_TEXTURES.has(powerup_type):
		sprite.texture = load(POWERUP_TEXTURES[powerup_type])

func _process(delta: float) -> void:
	position.y += fall_speed * delta
	
	# Gentle floating bob/rotation
	sprite.scale = Vector2(0.6, 0.6) + Vector2.ONE * sin(Time.get_ticks_msec() * 0.005) * 0.05
	aura_sprite.rotation += delta * 2.0
	
	if position.y > 750.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("paddle"):
		_collect()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("paddle"):
		_collect()

func _collect() -> void:
	AudioManager.play_sfx("powerup")
	Global.activate_powerup(powerup_type)
	
	var parent = get_parent()
	if parent and parent.has_method("spawn_fx"):
		parent.spawn_fx("res://assets/sprites/fx_glow_halo.tres", global_position, 0.5, 0.8, 1.8)
		
	queue_free()
