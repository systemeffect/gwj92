extends Node

var van_grid_loc: Vector2 = Vector2(0, 0)
var van_global_loc: Vector2 = Vector2(0, 0)
var van_global_dir: String = ""

var storm_locs : Array
var sensor_locs : Array
var sensors_collected : int
var current_turn = 0
var current_queue : Array
var turn_end_coords : Vector2
var fire_locs : Array
var flood_locs : Array
var cur_fire_attr : int = 0
var cur_flood_attr: int = 0
var cur_wind_attr: int = 0
var status_log : String = "[center]FOLTA STORMRUN-R\n-----------[/center]\nSelect 3 Attributes to Begin\n Tempest Manipulation"
