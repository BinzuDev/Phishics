@icon("res://icons/textbox.png")
class_name textBoxSettings extends Resource

@export var name : String = ""
@export_multiline var text : String = ""
@export var JFG_animation : String = ""
@export_enum("bottom", "top") var position : String = "bottom"
##This makes the text appear instantly instead of going letter by letter
@export var instant : bool = false
##Run a line of code when textbox shows up!
@export var code : String = ""
