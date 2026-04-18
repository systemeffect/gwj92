extends RichTextLabel

var loading_text = "FOLTA SYSTEMS STORMRUN-R\n------------------\nSelect Storm Attributes to Begin Tempest Manipulation\n"

func _ready() -> void:
	#update_text(loading_text)
	pass



func update_text(input_text:String)->void:
	#visible_characters = 0
	text += "\n" + input_text
	
	#for i in get_parsed_text():
		#visible_characters += 1
		#await get_tree().create_timer(0.1).timeout
