extends Control

#var show_grid_display: bool:
	#set(v): show_grid_display = v; queue_redraw()
#
#func toggle_grid_display(on: bool):
	#show_grid_display = on
	#
#func _draw() -> void:
	#if not grid
