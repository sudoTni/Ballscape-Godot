extends Node

# Level Layout Generator for Ballscape
const brick_scene = preload("res://scenes/brick.tscn")
const hazard_scene = preload("res://scenes/hazard.tscn")
const boss_scene = preload("res://scenes/boss.tscn")

static func load_level(game_scene: Node2D, level_num: int) -> int:
	var brick_count: int = 0
	
	match level_num:
		1: brick_count = _build_level_1(game_scene)
		2: brick_count = _build_level_2(game_scene)
		3: brick_count = _build_level_3(game_scene)
		4: brick_count = _build_level_4(game_scene)
		5: brick_count = _build_level_5(game_scene)
		6: brick_count = _build_level_6_boss(game_scene)
		99: brick_count = _build_level_custom(game_scene)
		_: brick_count = _build_level_1(game_scene)
			
	return brick_count

static func _spawn_brick(parent: Node2D, pos: Vector2, btype: int) -> Node2D:
	var b = brick_scene.instantiate()
	b.position = pos
	b.setup(btype)
	parent.add_child(b)
	return b

static func _spawn_hazard(parent: Node2D, pos: Vector2, htype: int) -> Node2D:
	var h = hazard_scene.instantiate()
	h.position = pos
	h.setup(htype)
	parent.add_child(h)
	return h

# LEVEL 1: Neon Beginnings
static func _build_level_1(parent: Node2D) -> int:
	var count: int = 0
	var start_x = 180.0
	var start_y = 140.0
	var cols = 8
	var rows = 4
	var spacing_x = 130.0
	var spacing_y = 70.0

	var row_types = [
		Global.BrickType.PURPLE,
		Global.BrickType.BLUE,
		Global.BrickType.GREEN,
		Global.BrickType.YELLOW,
		Global.BrickType.ORANGE,
		Global.BrickType.RED
	]

	for r in range(rows):
		for c in range(cols):
			var btype = row_types[r % row_types.size()]
			if (r + c) % 5 == 0:
				btype = Global.BrickType.POWERUP
			_spawn_brick(parent, Vector2(start_x + c * spacing_x, start_y + r * spacing_y), btype)
			count += 1

	return count

# LEVEL 2: Armored Fortress
static func _build_level_2(parent: Node2D) -> int:
	var count: int = 0
	var start_x = 180.0
	var start_y = 120.0
	var cols = 8
	var spacing_x = 130.0
	var spacing_y = 68.0

	_spawn_brick(parent, Vector2(640, 90), Global.BrickType.MOVING)
	count += 1

	for c in range(cols):
		var btype = Global.BrickType.ARMORED_GOLD if c == 0 or c == 7 else Global.BrickType.ARMORED_DARK
		_spawn_brick(parent, Vector2(start_x + c * spacing_x, start_y), btype)
		count += 1

	for c in range(cols):
		_spawn_brick(parent, Vector2(start_x + c * spacing_x, start_y + spacing_y), Global.BrickType.BLUE)
		count += 1

	for c in range(cols):
		var btype = Global.BrickType.POWERUP if c % 2 == 0 else Global.BrickType.DAMAGE_1
		_spawn_brick(parent, Vector2(start_x + c * spacing_x, start_y + spacing_y * 2), btype)
		count += 1

	_spawn_hazard(parent, Vector2(100, 320), Global.HazardType.BUMPER)
	_spawn_hazard(parent, Vector2(1180, 320), Global.HazardType.BUMPER)

	return count

# LEVEL 3: Explosive Chaos
static func _build_level_3(parent: Node2D) -> int:
	var count: int = 0
	var start_x = 180.0
	var start_y = 120.0
	var cols = 8
	var spacing_x = 130.0
	var spacing_y = 68.0

	for r in range(5):
		for c in range(cols):
			var btype = Global.BrickType.GREEN
			if (r + c) % 3 == 0:
				btype = Global.BrickType.EXPLOSIVE
			elif (r * c) % 2 == 1:
				btype = Global.BrickType.DAMAGE_2
			elif c == 3 or c == 4:
				btype = Global.BrickType.ORANGE
				
			_spawn_brick(parent, Vector2(start_x + c * spacing_x, start_y + r * spacing_y), btype)
			count += 1

	_spawn_hazard(parent, Vector2(640, 480), Global.HazardType.MINE)
	_spawn_hazard(parent, Vector2(300, 420), Global.HazardType.SPIKES)
	_spawn_hazard(parent, Vector2(980, 420), Global.HazardType.SPIKES)

	return count

# LEVEL 4: Portal Labyrinth
static func _build_level_4(parent: Node2D) -> int:
	var count: int = 0
	var start_x = 180.0
	var start_y = 120.0
	var cols = 8
	var spacing_x = 130.0
	var spacing_y = 68.0

	var p1 = _spawn_brick(parent, Vector2(250, 200), Global.BrickType.PORTAL_EXIT)
	var p2 = _spawn_brick(parent, Vector2(1030, 200), Global.BrickType.PORTAL_EXIT)
	p1.portal_target = p2
	p2.portal_target = p1
	count += 2

	_spawn_brick(parent, Vector2(640, 200), Global.BrickType.UNBREAKABLE)

	for r in range(1, 5):
		for c in range(cols):
			if (r == 1 and (c == 0 or c == 7 or c == 3 or c == 4)):
				continue
			var btype = Global.BrickType.PURPLE if r % 2 == 0 else Global.BrickType.YELLOW
			if c == 2 or c == 5:
				btype = Global.BrickType.ARMORED_DARK
			_spawn_brick(parent, Vector2(start_x + c * spacing_x, start_y + r * spacing_y), btype)
			count += 1

	_spawn_hazard(parent, Vector2(400, 460), Global.HazardType.ELECTRIC)
	_spawn_hazard(parent, Vector2(880, 460), Global.HazardType.ELECTRIC)

	return count

# LEVEL 5: Turret Assault
static func _build_level_5(parent: Node2D) -> int:
	var count: int = 0
	var start_x = 180.0
	var start_y = 110.0
	var cols = 8
	var spacing_x = 130.0
	var spacing_y = 68.0

	_spawn_hazard(parent, Vector2(150, 80), Global.HazardType.TURRET)
	_spawn_hazard(parent, Vector2(1130, 80), Global.HazardType.TURRET)

	_spawn_brick(parent, Vector2(400, 80), Global.BrickType.MOVING)
	_spawn_brick(parent, Vector2(880, 80), Global.BrickType.MOVING)
	count += 2

	for r in range(5):
		for c in range(cols):
			var btype = Global.BrickType.RED
			if r == 0:
				btype = Global.BrickType.ARMORED_GOLD
			elif r == 2 and (c == 2 or c == 5):
				btype = Global.BrickType.EXPLOSIVE
			elif r == 4:
				btype = Global.BrickType.POWERUP if c % 2 == 0 else Global.BrickType.PURPLE
			else:
				btype = Global.BrickType.ARMORED_DARK if (c + r) % 2 == 0 else Global.BrickType.BLUE

			_spawn_brick(parent, Vector2(start_x + c * spacing_x, start_y + r * spacing_y), btype)
			count += 1

	return count

# LEVEL 6: Mega Boss Battle
static func _build_level_6_boss(parent: Node2D) -> int:
	var boss = boss_scene.instantiate()
	boss.position = Vector2(640, 160)
	parent.add_child(boss)

	# Bumper side hazards
	_spawn_hazard(parent, Vector2(160, 300), Global.HazardType.BUMPER)
	_spawn_hazard(parent, Vector2(1120, 300), Global.HazardType.BUMPER)

	return 1

# CUSTOM LEVEL
static func _build_level_custom(parent: Node2D) -> int:
	var count: int = 0
	if FileAccess.file_exists("user://custom_level.json"):
		var file = FileAccess.open("user://custom_level.json", FileAccess.READ)
		if file:
			var json = JSON.new()
			if json.parse(file.get_as_text()) == OK:
				for item in json.data:
					var col = int(item["col"])
					var row = int(item["row"])
					var btype = int(item["type"])
					var pos = Vector2(180.0 + col * 130.0, 120.0 + row * 68.0)
					_spawn_brick(parent, pos, btype)
					count += 1
	if count == 0:
		count = _build_level_1(parent)
	return count
