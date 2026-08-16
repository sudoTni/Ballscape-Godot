extends Node2D

@onready var hud: CanvasLayer = $HUD
@onready var bottom_shield_line: Line2D = $BottomShieldLine
@onready var level_container: Node2D = $LevelContainer

var ball_scene = preload("res://scenes/ball.tscn")
var paddle_scene = preload("res://scenes/paddle.tscn")
var powerup_scene = preload("res://scenes/powerup.tscn")
var particle_fx_scene = preload("res://scenes/particle_fx.tscn")
var floating_text_scene = preload("res://scenes/floating_text.tscn")

var camera: Camera2D = null
var active_paddle: Node2D = null
var remaining_destructible_bricks: int = 0
var active_balls_count: int = 0

func _ready() -> void:
	Global.game_over.connect(_on_game_over)
	Global.powerup_activated.connect(_on_powerup_activated)
	Global.shield_state_changed.connect(_on_shield_state_changed)
	
	# Setup Camera with Shake
	camera = Camera2D.new()
	camera.set_script(load("res://scripts/camera_shake.gd"))
	add_child(camera)

	_setup_arena_walls()
	start_level()

func start_level() -> void:
	# Clear old nodes
	for child in level_container.get_children():
		child.queue_free()
		
	Global.start_new_game(Global.current_level)
	
	# Spawn Paddle
	active_paddle = paddle_scene.instantiate()
	active_paddle.position = Vector2(640, 660)
	level_container.add_child(active_paddle)

	# Spawn Initial Ball stuck to paddle
	spawn_ball_on_paddle()

	# Load Level Layout
	var level_loader = load("res://scripts/level_loader.gd")
	remaining_destructible_bricks = level_loader.load_level(level_container, Global.current_level)

	# Connect brick destruction signals
	for node in level_container.get_children():
		if node.is_in_group("regular_bricks"):
			node.brick_destroyed.connect(_on_brick_destroyed)
		elif node.is_in_group("boss"):
			node.boss_destroyed.connect(_on_level_cleared)

func spawn_ball_on_paddle() -> Node2D:
	var b = ball_scene.instantiate()
	b.position = active_paddle.position + Vector2(0, -30)
	b.is_stuck_to_paddle = true
	b.paddle_ref = active_paddle
	b.stuck_offset_x = 0.0
	b.ball_lost.connect(_on_ball_lost)
	level_container.add_child(b)
	active_balls_count += 1
	return b

func spawn_free_ball(pos: Vector2, dir: Vector2) -> void:
	var b = ball_scene.instantiate()
	b.position = pos
	b.is_stuck_to_paddle = false
	b.ball_lost.connect(_on_ball_lost)
	level_container.add_child(b)
	b.launch(dir)
	active_balls_count += 1

func _on_ball_lost(ball_node: Node2D) -> void:
	active_balls_count -= 1
	if active_balls_count <= 0:
		shake_camera(0.4)
		Global.lose_life()
		if Global.lives > 0:
			spawn_ball_on_paddle()

func _on_brick_destroyed(brick_node: Node2D) -> void:
	remaining_destructible_bricks -= 1
	spawn_floating_text("+%d" % brick_node.score_value, brick_node.global_position, Color(1.0, 0.9, 0.2))
	shake_camera(0.15)
	
	if remaining_destructible_bricks <= 0:
		_on_level_cleared()

func _on_level_cleared() -> void:
	Global.unlock_next_level()
	hud.show_level_clear()

func _on_game_over() -> void:
	hud.show_game_over()

func _on_powerup_activated(ptype: int, _dur: float) -> void:
	if ptype == Global.PowerupType.MULTIBALL:
		var balls = get_tree().get_nodes_in_group("balls")
		if balls.size() > 0:
			var main_ball = balls[0]
			spawn_free_ball(main_ball.position, Vector2(-0.6, -0.8).normalized())
			spawn_free_ball(main_ball.position, Vector2(0.6, -0.8).normalized())

func _on_shield_state_changed(active: bool) -> void:
	bottom_shield_line.visible = active

func spawn_powerup(pos: Vector2) -> void:
	var p = powerup_scene.instantiate()
	p.position = pos
	var types = Global.PowerupType.values()
	p.setup(types[randi() % types.size()])
	level_container.add_child(p)

func spawn_fx(tex_path: String, pos: Vector2, duration: float = 0.4, start_scale: float = 0.5, end_scale: float = 1.2, spin: float = 0.0) -> void:
	var fx = particle_fx_scene.instantiate()
	fx.position = pos
	fx.setup(tex_path, duration, start_scale, end_scale, spin)
	level_container.add_child(fx)

func spawn_floating_text(txt: String, pos: Vector2, color: Color = Color.YELLOW) -> void:
	var ft = floating_text_scene.instantiate()
	ft.position = pos
	ft.setup(txt, color, 0.7)
	level_container.add_child(ft)

func shake_camera(amount: float) -> void:
	if camera and camera.has_method("add_trauma"):
		camera.add_trauma(amount)

func _setup_arena_walls() -> void:
	_create_wall_collider(Vector2(Global.PLAYFIELD_LEFT - 10, 360), Vector2(20, 720))
	_create_wall_collider(Vector2(Global.PLAYFIELD_RIGHT + 10, 360), Vector2(20, 720))
	_create_wall_collider(Vector2(640, Global.PLAYFIELD_TOP - 10), Vector2(1280, 20))

func _create_wall_collider(pos: Vector2, size: Vector2) -> void:
	var body = StaticBody2D.new()
	body.position = pos
	body.collision_layer = 1
	body.collision_mask = 0
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	add_child(body)
