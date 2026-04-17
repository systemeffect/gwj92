extends RichTextLabel

var loading_text = "------------------\nFOLTA SYSTEMS STORMRUN-R\n------------------\nSelect Storm Attributes to Begin Tempest Manipulation\n"

func _ready() -> void:
	update_text(loading_text)

func update_text(input_text:String)->void:
	visible_characters = 0
	text += input_text + "\n"
	
	for i in get_parsed_text():
		visible_characters += 1
		await get_tree().create_timer(0.1).timeout
