extends Node3D

@export var van_body: Node3D

@export var max_wheel_turn_degrees: float = 900.0

#How much body lean corresponds to full wheel turn
@export var max_body_lean_degrees: float = 8.0

#Smoothing for the wheel
@export var wheel_follow_speed: float = 10.0

var base_rotation: Vector3

func _ready() -> void:
	base_rotation = rotation

func _process(delta: float) -> void:
	if van_body == null:
		return

	var body_lean_deg = rad_to_deg(van_body.rotation.z)

	var lean_ratio = clamp(body_lean_deg / max_body_lean_degrees, -1.0, 1.0)
	
	#Apparently this is the only way to make it not spin backwards
	lean_ratio *= -1.0

	var target_turn_rad = deg_to_rad(lean_ratio * max_wheel_turn_degrees)

	rotation.z = lerp(rotation.z, base_rotation.z + target_turn_rad, wheel_follow_speed * delta)
