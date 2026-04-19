extends PanelContainer

@onready var storms_created_num: Label = $Margin/VBox/Scorecard/StormsCreatedNum
@onready var sensors_collected_num: Label = $Margin/VBox/Scorecard/SensorsCollectedNum
@onready var fire_tiles_num: Label = $Margin/VBox/Scorecard/FireTilesNum
@onready var flood_tiles_num: Label = $Margin/VBox/Scorecard/FloodTilesNum
@onready var van_integrity_num: Label = $Margin/VBox/Scorecard/VanIntegrityNum
@onready var total_score_num: Label = $Margin/VBox/Scorecard/TotalScoreNum

var sensors_collected
var end_fire_tiles
var end_flood_tiles
var end_sensor_tiles
var storms_created
var van_integrity

func set_score_variables():
	end_fire_tiles = GlobalLocations.fire_locs
	end_flood_tiles = GlobalLocations.flood_locs
	end_sensor_tiles = GlobalLocations.sensor_locs
	sensors_collected = GlobalLocations.sensors_collected
	storms_created = GlobalLocations.cur_storm_count
	van_integrity = GlobalLocations.van_integrity
	storms_created_num.text = str(storms_created)
	sensors_collected_num.text = str(sensors_collected)
	fire_tiles_num.text = str(end_fire_tiles.size())
	flood_tiles_num.text = str(end_flood_tiles.size())
	van_integrity_num.text = "x " + str(van_integrity)
	
func set_final_score():
	set_score_variables()
	var final_score = end_fire_tiles.size() + end_flood_tiles.size() + end_sensor_tiles.size() + storms_created
	final_score = final_score * van_integrity
	total_score_num.text = str(final_score)


func _on_end_of_turn_button_pressed() -> void:
	set_final_score()
	pass # Replace with function body.
