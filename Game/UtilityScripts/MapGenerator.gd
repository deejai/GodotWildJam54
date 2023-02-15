var n_loot: int = 3
var n_mobs: int = 8
var room_size: int = 5
var floor_cols: int = 5
var floor_rows: int = 5
var map: Array[Array] = []

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

func get_door_tile_row_col(room_row, room_col, dir):
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

	if dir == "c":
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
	var iter_jump = [1, 5][randi() % 2] # 1 is forward, 5 is reverse
	for i in range(4):
		var dir = "nesw"[index]
		if can_open_wall(floor_row, floor_col, dir) and not opening_exists(floor_row, floor_col, dir):
			var op = ["door", "opening"][randi() % 2]
			if op == "door":
				build_door(floor_row, floor_col, dir)
			else:
				open_room_wall(floor_row, floor_col, dir)
			return true

		index = (index + iter_jump) % 4

	return false # room has all doors populated already

func label_room(room_row, room_col, label):
	assert(len(label) == 1)

	var coords = get_door_tile_row_col(room_row, room_col, "c")

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

	connected_rooms.add(current_coords)

	for dir in "nesw":
		if(opening_exists(current_coords[0], current_coords[1], dir)):
			floodfill_connected_rooms([
				current_coords[0] + (1 if dir == "s" else -1 if dir == "n" else 0),
				current_coords[1] + (1 if dir == "e" else -1 if dir == "w" else 0)
			], connected_rooms)

	return connected_rooms

func randomize_settings(level=0):
	room_size = randi_range(5, 6 + level / 3)
	floor_cols = randi_range(3 + level / 3, 4 + level / 2)
	floor_rows = randi_range(3 + level / 4, 4 + level / 3)
	n_loot = randi_range(2 + level / 4, 2 + (1 if level > 0 else 0) + level / 2)
	n_mobs = randi_range(5 + level / 2, 6 + level)

func pick_random_distinct_rooms(num):
	var chosen_rooms = Dictionary()
	for i in range(num):
		var coords
		while true:
			coords = [randi_range(0, floor_rows-1), randi_range(0, floor_cols-1)]
			if coords not in chosen_rooms:
				break
		chosen_rooms.add(coords)

	return chosen_rooms

func pick_empty_spot_in_room(room_row, room_col):
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
	var chosen_rooms = pick_random_distinct_rooms(n_mobs)

	for room_coords in chosen_rooms:
		var map_coords = pick_empty_spot_in_room(room_coords[0], room_coords[1])
		map[map_coords[0]][map_coords[1]] = "&"

func populate_loot():
	var chosen_rooms = pick_random_distinct_rooms(n_loot)

	for room_coords in chosen_rooms:
		var map_coords = pick_empty_spot_in_room(room_coords[0], room_coords[1])
		map[map_coords[0]][map_coords[1]] = "*"

func generate_floor():
	randomize_settings()
	initialize_map()
	initialize_connections()

	var start_coords = [
		[randi_range(0,1), randi_range(0,1)],
		[randi_range(floor_rows-2,floor_rows-2), randi_range(0,1)],
		[randi_range(0,1), randi_range(floor_cols-2,floor_cols-2)],
		[randi_range(floor_rows-2,floor_rows-2), randi_range(floor_cols-2,floor_cols-2)],
		][randi() % 4]

	var end_coords = [
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

	print_map()

	# print(f"floodfill iterations: {iterations}")

func test():
	for i in range(10):
		generate_floor()
