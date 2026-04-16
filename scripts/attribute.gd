class_name Attribute
extends Node

var attr_name : String
var attr_type : String
var attr_value : int
var spawns_fire : bool = false
var spawns_flood : bool = false
var spawns_wind : bool = false

func set_attribute(type : String, value: int):
	attr_type = type
	attr_name = attr_type.to_lower()
	attr_value = value
	match attr_type:
		"TEMPERATURE":
			spawns_fire = true
		"HUMIDITY":
			spawns_flood = true
		"PRESSURE":
			spawns_fire = true
			spawns_flood = true
		"WIND":
			spawns_wind = true
