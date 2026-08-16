extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var lifetime: float = 0.5
var timer: float = 0.0
var initial_scale: Vector2 = Vector2.ONE
var target_scale: Vector2 = Vector2(1.5, 1.5)
var spin_speed: float = 0.0

func setup(texture_path: String, duration: float = 0.5, start_scale: float = 1.0, end_scale: float = 1.4, spin: float = 0.0) -> void:
	lifetime = duration
	initial_scale = Vector2(start_scale, start_scale)
	target_scale = Vector2(end_scale, end_scale)
	spin_speed = spin
	
	if ResourceLoader.exists(texture_path):
		$Sprite2D.texture = load(texture_path)

func _ready() -> void:
	scale = initial_scale

func _process(delta: float) -> void:
	timer += delta
	var t: float = timer / lifetime
	if t >= 1.0:
		queue_free()
		return
		
	scale = initial_scale.lerp(target_scale, t)
	modulate.a = 1.0 - t
	if spin_speed != 0.0:
		rotation += spin_speed * delta
