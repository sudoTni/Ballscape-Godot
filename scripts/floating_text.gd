extends Node2D

@onready var label: Label = $Label

var text: String = "+100"
var color: Color = Color.YELLOW
var duration: float = 0.7
var timer: float = 0.0
var velocity: Vector2 = Vector2(0, -60.0)

func setup(txt: String, col: Color = Color.YELLOW, dur: float = 0.7) -> void:
	text = txt
	color = col
	duration = dur

func _ready() -> void:
	label.text = text
	label.add_theme_color_override("font_color", color)
	scale = Vector2(0.5, 0.5)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "position", position + Vector2(randf_range(-15, 15), -50), duration)
	tween.tween_property(label, "modulate:a", 0.0, duration).set_delay(duration * 0.4)

func _process(delta: float) -> void:
	timer += delta
	if timer >= duration:
		queue_free()
