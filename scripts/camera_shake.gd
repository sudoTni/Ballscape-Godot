extends Camera2D

var trauma: float = 0.0
var max_offset: Vector2 = Vector2(25, 20)
var max_roll: float = 0.08
var trauma_decay: float = 1.4

func _ready() -> void:
	anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	position = Vector2.ZERO

func add_trauma(amount: float) -> void:
	trauma = clampf(trauma + amount, 0.0, 1.0)

func _process(delta: float) -> void:
	if trauma > 0:
		trauma = maxf(trauma - trauma_decay * delta, 0.0)
		var shake = trauma * trauma
		rotation = max_roll * shake * randf_range(-1.0, 1.0)
		offset.x = max_offset.x * shake * randf_range(-1.0, 1.0)
		offset.y = max_offset.y * shake * randf_range(-1.0, 1.0)
	else:
		offset = Vector2.ZERO
		rotation = 0.0
