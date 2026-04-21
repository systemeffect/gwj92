extends RichTextLabel

var loading_text = "FOLTA SYSTEMS STORMRUN-R\n------------------\nSelect Storm Attributes to Begin Tempest Manipulation\n"

func update_text(input_text:String)->void:
	text += "\n" + input_text
	
