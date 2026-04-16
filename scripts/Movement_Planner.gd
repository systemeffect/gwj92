class_name MovementPlanner
extends RefCounted


static func build_directions(movement_queue: Array, starting_direction: String, all_cards: Dictionary) -> Dictionary:
	var directions: Array[Direction] = []
	var facing := starting_direction

	for card_id in movement_queue:
		var card = all_cards.get(card_id)
		if card == null:
			continue

		var attr = card.get("ATTRIBUTE_TYPE")
		var value = int(card.get("VALUE"))
		var move_dir := facing

		match attr:
			"TURNLEFT":
				facing = _turn_left(facing)
				move_dir = facing

			"TURNRIGHT":
				facing = _turn_right(facing)
				move_dir = facing

			"UTURN":
				facing = _u_turn(facing)
				move_dir = facing

			"FORWARD":
				move_dir = facing

			"REVERSE":
				move_dir = _u_turn(facing)

		var new_direction := Direction.new()
		new_direction.move_direction = move_dir
		new_direction.move_amount = value
		directions.append(new_direction)

	return {
		"directions": directions,
		"final_facing": facing
	}


static func _turn_left(dir: String) -> String:
	match dir:
		"NORTH":
			return "WEST"
		"EAST":
			return "NORTH"
		"SOUTH":
			return "EAST"
		"WEST":
			return "SOUTH"
	return dir


static func _turn_right(dir: String) -> String:
	match dir:
		"NORTH":
			return "EAST"
		"EAST":
			return "SOUTH"
		"SOUTH":
			return "WEST"
		"WEST":
			return "NORTH"
	return dir


static func _u_turn(dir: String) -> String:
	match dir:
		"NORTH":
			return "SOUTH"
		"EAST":
			return "WEST"
		"SOUTH":
			return "NORTH"
		"WEST":
			return "EAST"
	return dir
