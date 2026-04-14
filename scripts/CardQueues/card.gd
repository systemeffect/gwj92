extends Resource
class_name Card

enum DIRECTION { north, south, east, west }

var id: String
var type: String
var direction: DIRECTION
var amount: String
var description: String
var icon: String
var storm_type: String #probably make an enum for this
var storm_value: String #int or float?

func _init(json_data : Dictionary):
	id = json_data.get("ID")
	type = json_data.get("CARD_TYPE")
	direction = getDirection(json_data.get("MOVE_DIRECTION"))
	amount = json_data.get("MOVE_AMOUNT")
	description = json_data.get("CARD_DESCRIPTION")
	icon = json_data.get("CARD_ICON")
	storm_type = json_data.get("STORM_TYPE")
	storm_value = json_data.get("STORM_VALUE")

func getDirection(input: String) -> DIRECTION:
	match input:
		"north":
			return DIRECTION.north
		"south":
			return DIRECTION.south
		"east":
			return DIRECTION.east    
		"west":
			return DIRECTION.west
	return DIRECTION.north
