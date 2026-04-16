class_name Status
extends Node

var status_name : String
var status_type : int
var status_amount : int
var init_coord : Vector2
var affected_tiles : Array[Vector2]
var available_neighbors : Array[Vector2]

func _init() -> void:
	#find_neighbors(init_coord)
	pass

func spread_status():
	# check status type
	match status_type:
		1:
			# Fire
			
			pass
		2:
			# FLood
			pass

#func find_neighbors(coords : Vector2):
	##var x_coord = coords.x
	##var y_coord = coords.y
	#var up_coords = coords + Vector2(0,-1)
	#var down_coords = coords + Vector2(0,1)
	#var left_coords = coords + Vector2(-1,0)
	#var right_coords = coords + Vector2(1,0)
	## check to make sure its within the grid
	#if up_coords.y >= 0:
		#available_neighbors.append(up_coords)
	#if down_coords.y <= 11:
		#available_neighbors.append(down_coords)
	#if left_coords.x >= 0:
		#available_neighbors.append(left_coords)
	#if right_coords.x <= 11:
		#available_neighbors.append(right_coords)
	#print(available_neighbors)
