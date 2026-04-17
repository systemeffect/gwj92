extends TileMapLayer

var cur_fires : int
var cur_floods : int
# Arrays containing the affected tile info
var status_affected_tiles : Array
var fire_affected_tiles : Array
var flood_affected_tiles : Array
var debris_affected_tiles : Array

var available_neighbors : Array[Vector2]

var fire_status : Status
var flood_status : Status

func _ready() -> void:
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
		#if available_neighbors.has(pos):
			#available_neighbors.erase(pos)
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
			#print("printing neighbors: " + str(neighbors))
			for neighbor in neighbors:
				#print("looking at " + str(neighbor))
				var neighbor_data = get_cell_tile_data(neighbor)
				if neighbor_data == null:
					#var n_type = neighbor_data.get_custom_data("status")
					#if !n_type:
					available_cells.append(neighbor)
				else:
					#print("neighbor data null")
					pass
	return available_cells

func spread_available_cell(status : Status):
	var available = get_available_cells(status)
	var count = status.status_amount
	if available != null and available.size() > 0:
		var spread = available.pick_random()
		if spread != null:
			add_status_effect(status, spread)
			print("spread " + status.status_name)
			available.erase(spread)
	if count > 1:
		print('triggering count 2!')
		if available != null and available.size() > 0:
			var spread = available.pick_random()
			if spread != null:
				add_status_effect(status, spread)
				print("spread " + status.status_name)
				available.erase(spread)
	if count > 2:
		print('triggering count 3!')
		if available != null and available.size() > 0:
			var spread = available.pick_random()
			if spread != null:
				add_status_effect(status, spread)
				print("spread " + status.status_name)
				available.erase(spread)
