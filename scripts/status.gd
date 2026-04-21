class_name Status
extends Node

var status_name : String
# 1 = fire; 2 = flood, 3 = wind
var status_type : int
var status_amount : int
var init_coord : Vector2
var affected_tiles : Array[Vector2]
var available_neighbors : Array[Vector2]
