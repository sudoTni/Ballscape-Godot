extends Area2D

@export var speed: float = 800.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	position.y -= speed * delta
	if position.y < 40.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1)
		_spawn_impact_fx()
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(1)
		_spawn_impact_fx()
		queue_free()

func _spawn_impact_fx() -> void:
	AudioManager.play_sfx("brick_hit")
	var parent = get_parent()
	if parent and parent.has_method("spawn_fx"):
		parent.spawn_fx("fx_impact_spark.tres", global_position, 0.4)
