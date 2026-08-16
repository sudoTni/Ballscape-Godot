extends Control

@onready var grid_container: Control = $GridContainer
@onready var palette_container: HBoxContainer = $BottomPanel/MarginContainer/HBoxContainer/Palette
@onready var test_btn: Button = $TopBar/HBoxContainer/TestBtn
@onready var clear_btn: Button = $TopBar/HBoxContainer/ClearBtn
@onready var back_btn: Button = $TopBar/HBoxContainer/BackBtn
@onready var save_btn: Button = $TopBar/HBoxContainer/SaveBtn

var selected_brick_type: int = Global.BrickType.RED
var grid_bricks: Dictionary = {} # Vector2i(col, row) -> int (brick_type)

const COLS: int = 8
const ROWS: int = 6
const CELL_W: float = 130.0
const CELL_H: float = 68.0
const OFFSET_X: float = 180.0
const OFFSET_Y: float = 120.0

var brick_textures: Dictionary = {
	Global.BrickType.RED: "res://assets/sprites/brick_red.tres",
	Global.BrickType.ORANGE: "res://assets/sprites/brick_orange.tres",
	Global.BrickType.YELLOW: "res://assets/sprites/brick_yellow.tres",
	Global.BrickType.GREEN: "res://assets/sprites/brick_green.tres",
	Global.BrickType.BLUE: "res://assets/sprites/brick_blue.tres",
	Global.BrickType.PURPLE: "res://assets/sprites/brick_purple.tres",
	Global.BrickType.ARMORED_DARK: "res://assets/sprites/brick_armored_dark.tres",
	Global.BrickType.ARMORED_GOLD: "res://assets/sprites/brick_armored_gold.tres",
	Global.BrickType.UNBREAKABLE: "res://assets/sprites/brick_unbreakable.tres",
	Global.BrickType.EXPLOSIVE: "res://assets/sprites/brick_explosive.tres",
	Global.BrickType.POWERUP: "res://assets/sprites/brick_powerup.tres",
	Global.BrickType.MOVING: "res://assets/sprites/brick_moving.tres"
}

func _ready() -> void:
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	clear_btn.pressed.connect(_clear_grid)
	test_btn.pressed.connect(_test_custom_level)
	save_btn.pressed.connect(_save_custom_level)

	_build_palette()
	_load_custom_level()

func _build_palette() -> void:
	for child in palette_container.get_children():
		child.queue_free()

	for btype in brick_textures.keys():
		var btn = TextureButton.new()
		btn.custom_minimum_size = Vector2(50, 30)
		btn.texture_normal = load(brick_textures[btype])
		btn.ignore_texture_size = true
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		var type_copy = btype
		btn.pressed.connect(func(): selected_brick_type = type_copy)
		palette_container.add_child(btn)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var pos = event.position
		var col = int((pos.x - OFFSET_X + CELL_W * 0.5) / CELL_W)
		var row = int((pos.y - OFFSET_Y + CELL_H * 0.5) / CELL_H)
		
		if col >= 0 and col < COLS and row >= 0 and row < ROWS:
			var cell_key = Vector2i(col, row)
			if event.button_index == MOUSE_BUTTON_LEFT:
				grid_bricks[cell_key] = selected_brick_type
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				grid_bricks.erase(cell_key)
			queue_redraw()

func _draw() -> void:
	# Draw level editor grid slots and placed bricks
	for r in range(ROWS):
		for c in range(COLS):
			var pos = Vector2(OFFSET_X + c * CELL_W, OFFSET_Y + r * CELL_H)
			draw_rect(Rect2(pos - Vector2(55, 25), Vector2(110, 50)), Color(0.2, 0.3, 0.5, 0.3), false, 2.0)

	for cell_key in grid_bricks.keys():
		var btype = grid_bricks[cell_key]
		var pos = Vector2(OFFSET_X + cell_key.x * CELL_W, OFFSET_Y + cell_key.y * CELL_H)
		if brick_textures.has(btype):
			var tex = load(brick_textures[btype])
			draw_texture_rect(tex, Rect2(pos - Vector2(55, 25), Vector2(110, 50)), false)

func _clear_grid() -> void:
	grid_bricks.clear()
	queue_redraw()

func _test_custom_level() -> void:
	_save_custom_level()
	Global.current_level = 99 # Custom Level ID
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _save_custom_level() -> void:
	var data = []
	for k in grid_bricks.keys():
		data.append({"col": k.x, "row": k.y, "type": grid_bricks[k]})
	var file = FileAccess.open("user://custom_level.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func _load_custom_level() -> void:
	if FileAccess.file_exists("user://custom_level.json"):
		var file = FileAccess.open("user://custom_level.json", FileAccess.READ)
		if file:
			var text = file.get_as_text()
			var json = JSON.new()
			if json.parse(text) == OK:
				var data = json.data
				grid_bricks.clear()
				for item in data:
					grid_bricks[Vector2i(item["col"], item["row"])] = int(item["type"])
				queue_redraw()
