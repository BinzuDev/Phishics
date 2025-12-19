@icon("res://Icons/textbox.png")
class_name TextboxSettings extends Resource

##This is what appears in the name box
@export var name : String = ""
##you can use "|" to add a manual 20 frames wait.[br]
##BBCODE cheatsheet: [​b]: [b]bold[/b] [​i]: [i]italic[/i]   
##image: [​img=65]file_link[/img] [​font_size=40] [color=ff00ff]color[/color]: [​color=ff00ff]
@export_multiline var text : String = ""
@export var JFG_animation : String = ""
@export_enum("bottom", "top") var position : String = "bottom"
##This makes the text appear instantly instead of going letter by letter
@export var instant : bool = false
##Select which camera override from the list in the dialogue settings should this textbox use. Use -1 for the default fish cam. Ignore if the cam override list is empty.
@export_range(-1, 99) var cam_override : int = 0
##Run a line of code when textbox shows up! Look at the tooltip of "Code Post Dialogue" for more info.
@export var code : String = ""
