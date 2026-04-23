extends TileMapLayer

signal update_status_log
signal load_storms

# Level Tilemaps
@onready var onboarding: TileMapLayer = $"../Onboarding"
@onready var jam_map: TileMapLayer = $"../JamMap"
@onready var four_corners: TileMapLayer = $"../FourCorners"
@onready var urban_sprawl: TileMapLayer = $"../UrbanSprawl"
@onready var choppy: TileMapLayer = $"../Choppy"
@onready var commute: TileMapLayer = $"../Commute"
@onready var maze: TileMapLayer = $"../Maze"
@onready var bonus: TileMapLayer = $"../Bonus"
@onready var timorous: TileMapLayer = $"../Timorous"
@onready var solar: TileMapLayer = $"../Solar"
@onready var starburst: TileMapLayer = $"../Starburst"


var current_level : TileMapLayer
var current_level_index : int
var current_level_data : Dictionary
var levels_import ={}
var cur_storms : int
var cur_fires : int
var cur_floods : int
# Arrays containing the affected tile info
var status_affected_tiles : Array
var fire_affected_tiles : Array
var flood_affected_tiles : Array
var sensor_tiles : Array
var obstacle_affected_tiles : Array

var available_neighbors : Array[Vector2]

var fire_status : Status
var flood_status : Status

func _ready() -> void:
	load_storm_data()
	fire_status = Status.new()
	fire_status.status_type = 1

func add_status_effect(status : Status, pos : Vector2):
	#replace vector with status var
	if !status_affected_tiles.has(pos):
		match status.status_type:
			0:
				erase_cell(pos)
				#clear from array
			1:
				#Fire
				set_cell(pos, 0, Vector2(2,0))
			2:
				# Flood
				set_cell(pos, 0, Vector2(3,0))
			3:
				# Sensor
				set_cell(pos, 0, Vector2(4,0))
			4:
				# Debris/Obstacle
				set_cell(pos, 0, Vector2(5,0))
		status_affected_tiles.append(pos)

func get_sensor_zones() -> Array:
	var cells_in_use = get_used_cells_by_id(0,Vector2(4,0))
	return cells_in_use

func get_available_cells(status_type : Status) -> Array:
	var type = status_type.status_name
	var currently_affected = get_used_cells()
	var available_cells = []
	for status in currently_affected:
		var cell_data = get_cell_tile_data(status)
		var cell_type = cell_data.get_custom_data(type)
		if cell_type:
			var neighbors = get_surrounding_cells(status)
			for neighbor in neighbors:
				var neighbor_data = get_cell_tile_data(neighbor)
				if neighbor_data == null:
					available_cells.append(neighbor)
	return available_cells

func spread_available_cell(status : Status):
	var available = get_available_cells(status)
	var count = status.status_amount
	if available != null and available.size() > 0:
		while count > 0:
			var spread = available.pick_random()
			if spread != null:
				add_status_effect(status, spread)
				update_status_log.emit(status)
				available.erase(spread)
			else:
				break
			count -= 1
			
func set_level(level_index : int):
	current_level_index = level_index
	current_level_data = get_level_by_id(str(level_index))
	match level_index:
		0:
			current_level = onboarding
		1:
			current_level = jam_map
		2:
			current_level = four_corners
		3:
			current_level = urban_sprawl
		4:
			current_level = choppy
		5:
			current_level = commute
		6:
			current_level = maze
		7:
			current_level = bonus
		8:
			current_level = timorous
		9:
			current_level = solar
		10:
			current_level = starburst
	set_van_start_pos()
	load_level_tiles()

func load_level_tiles():
	clear()
	get_new_level_tiles()
	build_level(fire_affected_tiles, Util.fire_atlas)
	build_level(flood_affected_tiles, Util.flood_atlas)
	build_level(sensor_tiles, Util.sensor_atlas)
	build_level(obstacle_affected_tiles, Util.obstacle_atlas)
	var storm_array = load_level_storms()
	load_storms.emit(storm_array)
	
func build_level(tiles : Array, atlas : Vector2):
	for tile in tiles:
		set_cell(tile, 0, atlas)

func load_level_storms() -> Array:
	var level_data = get_level_by_id(str(current_level_index))
	var storm_amt = level_data.get("STORMS_TOTAL")
	cur_storms = storm_amt
	var storm_origins = []
	storm_origins.resize(storm_amt)
	var storm_index = 1
	for storm in storm_origins:
		var origin_string = "STORM_" + str(storm_index) + "_ORIGIN"
		storm_origins.set(int(storm_index - 1),level_data.get(origin_string))
		storm_index += 1
	return storm_origins
	
func get_new_level_tiles():
	fire_affected_tiles = current_level.get_used_cells_by_id(0, Util.fire_atlas)
	flood_affected_tiles = current_level.get_used_cells_by_id(0, Util.flood_atlas)
	sensor_tiles = current_level.get_used_cells_by_id(0, Util.sensor_atlas)
	obstacle_affected_tiles = current_level.get_used_cells_by_id(0, Util.obstacle_atlas)
	
func set_van_start_pos():
	var start_loc = current_level_data.get("VAN_START")
	start_loc = str_to_var("Vector2" + start_loc)
	GlobalLocations.van_grid_loc = start_loc
	GlobalLocations.van_global_loc = map_to_local(start_loc)
	
#JSON funcs
func load_storm_data():
	var json_data = Util.load_json_data_from_path()
	if json_data != null:
		var levels = json_data.get("Stormloader")
		if levels != null:
			for i in range(0, levels.size()):
				var level_id = str(i)
				if levels.has(level_id):
					levels_import[level_id] = parse_level_data_from_json(i, levels[level_id])


func parse_level_data_from_json(id, json_data : Dictionary):
	#Creates dictionary to hold at card attributes
	var level_attributes = {}
	# Extract all attribute data from json
	level_attributes["ID"] = id
	
	level_attributes["LEVEL"] = json_data.get("LEVEL")
	level_attributes["VAN_START"] = json_data.get("VAN_START")
	level_attributes["SENSORS_TOTAL"] = json_data.get("SENSORS_TOTAL")
	level_attributes["STORMS_TOTAL"] = json_data.get("STORMS_TOTAL")
	level_attributes["STORM_1_ORIGIN"] = json_data.get("STORM_1_ORIGIN")
	level_attributes["STORM_2_ORIGIN"] = json_data.get("STORM_2_ORIGIN")
	level_attributes["STORM_3_ORIGIN"] = json_data.get("STORM_3_ORIGIN")
	level_attributes["STORM_4_ORIGIN"] = json_data.get("STORM_4_ORIGIN")
	level_attributes["STORM_5_ORIGIN"] = json_data.get("STORM_5_ORIGIN")
	level_attributes["STORM_6_ORIGIN"] = json_data.get("STORM_6_ORIGIN")
	level_attributes["STORM_7_ORIGIN"] = json_data.get("STORM_7_ORIGIN")
	level_attributes["STORM_8_ORIGIN"] = json_data.get("STORM_8_ORIGIN")
	level_attributes["STORM_9_ORIGIN"] = json_data.get("STORM_9_ORIGIN")
	
	return level_attributes

func get_level_by_id(level_id: String) -> Dictionary:
	if levels_import.has(level_id):
		return levels_import[level_id]
	else:
		print("level ID NOT FOUND")
		return {}
	
