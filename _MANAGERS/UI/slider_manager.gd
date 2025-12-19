@tool
class_name customSlider extends HSlider


@export var sliderName : String = "Label"

@export_multiline var helpText : String = ""

var mouseHovered : bool = false

func _ready():
	toolShit()

func toolShit():
	%nameLabel.text = sliderName
	if min_value == 0:
		%numberLabel.text = str(roundi(value/max_value*100), "%")
	else:
		%numberLabel.text = str(roundi(value*100), "%")
	
	var length = max(custom_minimum_size.x, size.x)
	%numberLabel.position.x = length+17
	

func _process(_delta):
	if Engine.is_editor_hint():
		toolShit()

func set_percentage(newValue:int):
	%numberLabel.text = str(newValue, "%")

func set_custom_value(newValue:String):
	%numberLabel.text = newValue
	


func _on_focus_entered():
	MenuManager.set_help_tip(helpText)



func _on_mouse_entered():
	mouseHovered = true
	grab_focus()

func _on_mouse_exited():
	mouseHovered = false
	
