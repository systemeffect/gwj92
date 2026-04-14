extends Resource
class_name Card

enum DIRECTION { north, south, east, west }

var id: String
var type: String
var direction: DIRECTION
var amount: float
var description: String
var icon: String
var storm_type: String #probably make an enum for this
var storm_value: int #int or float?

func _init(_id: String, json_data : Dictionary):
	id = _id
	type = json_data.get("CARD_TYPE")
	direction = getDirection(json_data.get("MOVE_DIRECTION"))
	amount = json_data.get("MOVE_AMOUNT")
	description = json_data.get("CARD_DESCRIPTION")
	icon = json_data.get("CARD_ICON")
	storm_type = json_data.get("STORM_TYPE")
	storm_value = json_data.get("STORM_VALUE")

func getDirection(input: String) -> DIRECTION:
	match input:
		"NORTH":
			return DIRECTION.north
		"SOUTH":
			return DIRECTION.south
		"EAST":
			return DIRECTION.east    
		"WEST":
			return DIRECTION.west
	return DIRECTION.north
