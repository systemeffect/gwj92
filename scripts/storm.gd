extends Node2D


@export var origin_pos : Vector2

@onready var sprite: Sprite2D = $Sprite
@onready var zone_label: Label = $ZoneLabel
@onready var label_anim: AnimationPlayer = $LabelAnim


var direction : Vector2
var variance = randf_range(-0.1, 0.1)
var wind_change_var = randf_range(-1.0, 1.0)
var storm_speed : float = 8.0
var speed_incr : float = 10.0

# Storm will spawn on origin_pos and will generate a random vector
# which it will drift toward. Add a small range it will deviate from
# that direction to mimic a more natural path. 

# Somewhere to collect the various statuses the storm has (from
# un-used cards)
var status_attributes = []

func _ready() -> void:
	self.position = origin_pos
	direction = Vector2.from_angle((randf_range(0, TAU)))
	pass
	
func _process(delta: float) -> void:
	self.position += direction * storm_speed * delta
	variance = randf_range(-0.1, 0.1)
	direction = direction.rotated(variance)
	sprite.rotation += 1 * delta
	pass
	# Write function to determine storm direction with drift
	# Move the storm in new direction at set speed

func set_storm_speed(wind : int):
	storm_speed = (speed_incr * wind) + speed_incr
	print("changing speed: " + str(storm_speed))

func set_storm_direction(dir : Direction):
	var new_direction = dir.move_direction
	match new_direction:
		"NORTH":
			direction = Vector2(0, -1)
			var wind_variance = wind_change_var
			direction = direction.rotated(wind_variance)
		"EAST":
			direction = Vector2(1, 0)
			var wind_variance = wind_change_var
			direction = direction.rotated(wind_variance)
		"SOUTH":
			direction = Vector2(0, 1)
			var wind_variance = wind_change_var
			direction = direction.rotated(wind_variance)
		"WEST":
			direction = Vector2(-1, 0)
			var wind_variance = wind_change_var
			direction = direction.rotated(wind_variance)
			
func set_storm_status(status):
	# receives the status and adds it to the current status array
	status_attributes.append(status)

func dropped_status(status: Status):
	zone_label.show()
	match status.status_type:
		1:
			#fire
			zone_label.text = "Fire Zone Created!"
			pass
		2:
			#flood
			zone_label.text = "Flood Zone Created!"
			pass
	label_anim.play("zone_dropped")
	await label_anim.animation_finished
	zone_label.hide()
	
func set_origin(pos : Vector2):
	origin_pos = pos
	position = pos
