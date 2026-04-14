extends Node2D


var origin_pos : Vector2
var direction : Vector2
var storm_speed : Vector2

# Storm will spawn on origin_pos and will generate a random vector
# which it will drift toward. Add a small range it will deviate from
# that direction to mimic a more natural path. 

# Somewhere to collect the various statuses the storm has (from
# un-used cards)
var status_attributes = []

func _ready() -> void:
	self.position = origin_pos
	pass
	
func _process(delta: float) -> void:
	pass
	# Write function to determine storm direction with drift
	# Move the storm in new direction at set speed
	
