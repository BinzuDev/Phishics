@tool
class_name customSlider
extends HSlider

@export var sliderName : String = "Label"

@export var helpText : String = ""


func _ready():
	toolShit()

func toolShit():
	%nameLabel.text = sliderName
	%numberLabel.text = str(roundi(value/max_value*100), "%")
	var length = max(custom_minimum_size.x, size.x)
	%numberLabel.position.x = length+17
	

func _process(_delta):
	if Engine.is_editor_hint():
		toolShit()

func set_percentage(newValue:int):
	%numberLabel.text = str(newValue, "%")

func set_custom_value(newValue:String):
	%numberLabel.text = newValue
	
