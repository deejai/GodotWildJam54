extends Node2D

var level: int = Main.level

var wall = load("res://Game/Objects/Structural/DungeonWallDark.tscn")
var wall_bot = load("res://Game/Objects/Structural/DungeonWallDark.tscn")
var wall_top = load("res://Game/Objects/Structural/DungeonWallDark.tscn")
var tile = load("res://Game/Objects/Structural/DungeonTile.tscn")
var tile_mossy = load("res://Game/Objects/Structural/DungeonTileMossy.tscn")
var rubble = load("res://Game/Objects/Structural/DungeonRubble.tscn")
var mob_orange = load("res://Game/Characters/BlueberryMonster.tscn")
var mob_banana = load("res://Game/Characters/BananaMonster.tscn")
var item = load("res://Game/Objects/Item.tscn")
var heal = load("res://Game/Objects/Heal.tscn")
var exit = load("res://Game/Objects/DungeonExit.tscn")
var deal = load("res://Game/Objects/DealWithTheDevil.tscn")

var n_loot: int = 3
var n_mobs: int = 8
var room_size: int = 5
var floor_cols: int = 5
var floor_rows: int = 5
var map: Array[Array] = []
var all_room_coords: Array[Array] = []

var start_coords
var end_coords

var timer: float = 120

func initialize_map():
	map = []

	for row_n in range(1 + floor_rows * (room_size + 1)):
		var row = []
		for col_n in range(1 + floor_cols * (room_size + 1)):
			if ((row_n % (room_size + 1)) == 0) or ((col_n % (room_size + 1)) == 0):
				row.append("X")
			else:
				row.append(" ")
		map.append(row)

	all_room_coords = []
	
	for floor_row in floor_rows:
		for floor_col in floor_cols:
			all_room_coords.append([floor_row, floor_col])

func can_open_wall(room_row: int, room_col: int, dir: String):
	assert(room_row >= 0 and room_row < floor_rows)

	assert(room_col >= 0 and room_col < floor_cols)

	if dir == "n" and room_row == 0:
		return false
	
	if dir == "e" and room_col == floor_cols-1:
		return false
	
	if dir == "s" and room_row == floor_rows-1:
		return false
	
	if dir == "w" and room_col == 0:
		return false

	return true

func build_door(room_row: int, room_col: int, dir: String):
	assert(not (room_row < 0 or room_row > floor_rows))

	assert(not (room_col < 0 or room_col > floor_cols))

	assert(not (dir == "n" and room_row == 0))
	
	assert(not (dir == "e" and room_col == floor_cols-1))
	
	assert(not (dir == "s" and room_row == floor_rows-1))
	
	assert(not (dir == "w" and room_col == 0))

	var coords = get_door_tile_row_col(room_row, room_col, dir)

	map[coords[0]][coords[1]] = "D"

func get_door_tile_row_col(room_row: int, room_col: int, dir: String):
	var row_n: int
	var col_n: int

	if dir == "n":
		row_n = (room_size + 1) * room_row
		col_n = (room_size + 1)/2 + (room_size + 1) * room_col
	
	if dir == "e":
		row_n = (room_size + 1)/2 + (room_size + 1) * room_row
		col_n = (room_size + 1) * (room_col + 1)
	
	if dir == "s":
		row_n = (room_size + 1) * (room_row + 1)
		col_n = (room_size + 1)/2 + (room_size + 1) * room_col
	
	if dir == "w":
		row_n = (room_size + 1)/2 + (room_size + 1) * room_row
		col_n = (room_size + 1) * room_col

	if dir == "center":
		row_n = (room_size + 1)/2 + (room_size + 1) * room_row
		col_n = (room_size + 1)/2 + (room_size + 1) * room_col

	if dir == "topleft":
		row_n = (room_size + 1) * room_row
		col_n = (room_size + 1) * room_col

	return [row_n, col_n]

func get_wall_coords(room_row, room_col, dir):
	var door_coords = get_door_tile_row_col(room_row, room_col, dir)

	var wall_coords = []

	if dir in "ns":
		for i in range(1 - room_size % 2, room_size + 1 - (room_size % 2)):
			wall_coords.append([door_coords[0], door_coords[1] + i - room_size / 2])

	elif dir in "ew":
		for i in range(1 - room_size % 2, room_size + 1 - (room_size % 2)):
			wall_coords.append([door_coords[0] + i - room_size / 2, door_coords[1]])

	else:
		assert(false)

	return wall_coords

func opening_exists(room_row, room_col, dir):
	var coords = get_door_tile_row_col(room_row, room_col, dir)
	return map[coords[0]][coords[1]] != "X"

func open_room_wall(room_row, room_col, dir):
	assert(can_open_wall(room_row, room_col, dir))

	var wall_coords = get_wall_coords(room_row, room_col, dir)

	for coords in wall_coords:
		map[coords[0]][coords[1]] = " "

func initialize_connections():
	for floor_row in range(floor_rows):
		for floor_col in range(floor_cols):
			build_random_connection_in_room(floor_row, floor_col)

func build_random_connection_in_room(floor_row, floor_col):
	var index = randi_range(0, 3)
	var iter_jump = [1, 5].pick_random() # 1 is forward, 5 is reverse
	for i in range(4):
		var dir = "nesw"[index]
		if can_open_wall(floor_row, floor_col, dir) and not opening_exists(floor_row, floor_col, dir):
			var op = ["door", "opening"].pick_random()
			if op == "door":
				build_door(floor_row, floor_col, dir)
			else:
				open_room_wall(floor_row, floor_col, dir)
			return true

		index = (index + iter_jump) % 4

	return false # room has all doors populated already

func label_room(room_row, room_col, label):
	assert(len(label) == 1)

	var coords = get_door_tile_row_col(room_row, room_col, "center")

	map[coords[0]][coords[1]] = label

func print_map():
	for row in map:
		var out = ""
		for col in row:
			out += str(col) 
		print(out)

func floodfill_connected_rooms(current_coords, connected_rooms = null):
	if connected_rooms == null:
		connected_rooms = Dictionary()

	if current_coords in connected_rooms:
		return connected_rooms

	connected_rooms[current_coords] = true

	for dir in "nesw":
		if(opening_exists(current_coords[0], current_coords[1], dir)):
			floodfill_connected_rooms([
				current_coords[0] + (1 if dir == "s" else -1 if dir == "n" else 0),
				current_coords[1] + (1 if dir == "e" else -1 if dir == "w" else 0)
			], connected_rooms)

	return connected_rooms

func randomize_settings():
	room_size = randi_range(4, 4 + (level-1) / 2)
	floor_cols = randi_range(3 + (level-1) / 3, 4 + (level-1) / 2)
	floor_rows = randi_range(3 + (level-1) / 4, 4 + (level-1) / 3)
	n_loot = randi_range(2 + (level-1) / 4, 2 + (1 if level > 1 else 0) + (level-1) / 2)
	n_mobs = randi_range(8 + (level-1) / 2, 10 + 3 * (level-1))

func pick_random_distinct_rooms(num: int, avoid=[]):
	assert(avoid.all(func(_coords): return len(_coords) == 2))

	var room_choices = all_room_coords.filter(func(_coords): return _coords not in avoid)
	var chosen_rooms = Dictionary()
	for i in range(num):
		if room_choices.is_empty():
			print("Ran out of room space")
			break

		var coords

		if len(chosen_rooms) >= len(room_choices):
			coords = room_choices.pick_random()
		else:
			coords = room_choices.filter(func(_coords): return _coords not in chosen_rooms).pick_random()

		if coords in chosen_rooms:
			chosen_rooms[coords] += 1
			if chosen_rooms[coords] >= (room_size * room_size) / 2:
				room_choices.remove_at(room_choices.find(coords))
		else:
			chosen_rooms[coords] = 1

	return chosen_rooms

func pick_empty_spot_in_room(room_row: int, room_col: int):
	var topleft_coords = get_door_tile_row_col(room_row, room_col, "topleft")

	var coords

	while true:
		coords = [
			topleft_coords[0] + randi_range(1, room_size),
			topleft_coords[1] + randi_range(1, room_size)
		]

		if map[coords[0]][coords[1]] == " ":
			break

	return coords

func populate_mobs():
	var chosen_rooms = pick_random_distinct_rooms(n_mobs, [start_coords])

	for room_coords in chosen_rooms:
		for i in range(chosen_rooms[room_coords]):
			var map_coords = pick_empty_spot_in_room(room_coords[0], room_coords[1])
			map[map_coords[0]][map_coords[1]] = "&"

func populate_loot():
	var chosen_rooms = pick_random_distinct_rooms(n_loot, [start_coords])

	for room_coords in chosen_rooms:
		for i in range(chosen_rooms[room_coords]):
			var map_coords = pick_empty_spot_in_room(room_coords[0], room_coords[1])
			map[map_coords[0]][map_coords[1]] = "*"

func populate_heal():
	var room_coords = pick_random_distinct_rooms(1, [start_coords, end_coords]).keys()[0]
	var map_coords = pick_empty_spot_in_room(room_coords[0], room_coords[1])
	map[map_coords[0]][map_coords[1]] = "+"

func populate_deal():
	var room_coords = pick_random_distinct_rooms(1, [start_coords, end_coords]).keys()[0]
	var map_coords = pick_empty_spot_in_room(room_coords[0], room_coords[1])
	map[map_coords[0]][map_coords[1]] = "d"

func generate_floor_map():
	randomize_settings()
	initialize_map()
	initialize_connections()

	start_coords = [
		[randi_range(0,1), randi_range(0,1)],
		[randi_range(floor_rows-2,floor_rows-2), randi_range(0,1)],
		[randi_range(0,1), randi_range(floor_cols-2,floor_cols-2)],
		[randi_range(floor_rows-2,floor_rows-2), randi_range(floor_cols-2,floor_cols-2)],
		].pick_random()

	end_coords = [
		(start_coords[0] + floor_rows / 2) % floor_rows,
		(start_coords[1] + floor_cols / 2) % floor_cols
		]

	var floodfill_results = floodfill_connected_rooms(start_coords)

	var iterations = 1
	while len(floodfill_results) != floor_rows * floor_cols:
		for i in range(5):
			build_random_connection_in_room(randi_range(0, floor_rows-1), randi_range(0, floor_cols-1))

		floodfill_results = floodfill_connected_rooms(start_coords)
		iterations += 1

	label_room(start_coords[0], start_coords[1], "S")
	label_room(end_coords[0], end_coords[1], "E")

	populate_mobs()
	populate_loot()
	populate_heal()
	if level % Main.boss_floor_cadence == Main.boss_floor_cadence - 1:
		populate_deal()

func create():
	add_child(Main.player)

	generate_floor_map()

	var tilescale = 100.0
	var start_tile_coords = get_door_tile_row_col(start_coords[0], start_coords[1], "center")
	var offset_x = -start_tile_coords[1] * tilescale
	var offset_y = -start_tile_coords[0] * tilescale

	var colormod = Color(.8 + randf() * .2, .8 + randf() * .2, .8 + randf() * .2, 1)

	for row_n in len(map):
		for col_n in len(map[row_n]):
			var bg_obj = null
			var fg_obj = null
			var glyph = map[row_n][col_n]
			var selected_tile = tile if randf() < .95 else tile_mossy
			match(glyph):
				"X":
					if row_n == len(map)-1:
						bg_obj = wall_bot.instantiate()
					elif row_n % (room_size + 1) == 0:
						if map[row_n+1][col_n] == "X":
							bg_obj = wall.instantiate()
						else:
							bg_obj = wall_top.instantiate()
					else:
						bg_obj = wall.instantiate()
				" ":
					bg_obj = selected_tile.instantiate()
				"&":
					bg_obj = selected_tile.instantiate()
					fg_obj = [mob_orange, mob_banana].pick_random().instantiate()
				"*":
					bg_obj = selected_tile.instantiate()
					fg_obj = item.instantiate()
					fg_obj.randomize(level)
				"+":
					bg_obj = selected_tile.instantiate()
					fg_obj = heal.instantiate()
				"S":
					bg_obj = selected_tile.instantiate()
					fg_obj = rubble.instantiate()
				"E":
					bg_obj = selected_tile.instantiate()
					fg_obj = exit.instantiate()
				"d":
					bg_obj = selected_tile.instantiate()
					fg_obj = deal.instantiate()
				_:
					bg_obj = selected_tile.instantiate()

			var world_pos = Vector2(offset_x + col_n * tilescale, offset_y + row_n * tilescale)

			if bg_obj:
				bg_obj.position = world_pos
				bg_obj.z_index = -10
				
				bg_obj.modulate = colormod

				add_child(bg_obj)

			if fg_obj:
				fg_obj.position = world_pos

				if fg_obj is Character:
					fg_obj.z_index = 10
				elif glyph in ["S", "E", "+", "*", "d"]:
					fg_obj.z_index = -5

				add_child(fg_obj)

func _ready():
	create()
	Main.floor_instance = self
	Main.player.position = Vector2.ZERO
	Main.music.set_track(MusicServer.Track.DUNGEON1 if level >= Main.boss_floor_cadence else MusicServer.Track.DUNGEON2)
	Main.floor_timer_begin(55.0 + 3.0 * (level-1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
