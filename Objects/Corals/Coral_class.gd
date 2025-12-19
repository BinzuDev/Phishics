@tool
@icon("res://Icons/coral.png")
class_name Coral extends Node3D

@export_tool_button("Generate random color") var action = setRandColor
func setRandColor():
	var hue = randf_range(0.0, 1.0)
	var sat = 0.5
	##Because of the world environment, it makes reds way LESS saturated
	##and teals way MORE saturated, so I have to compensate here
	if (hue > 0.133 and hue < 0.833): #less saturated when blue-green
		sat = 0.4
	else: #more saturated when red
		sat = 0.6
	sat += randf_range(-0.08, 0.08) #extra randomness
	var val = 1.0
	if (hue > 0.45 and hue < 0.547):
		val = 0.85 #darker when perfectly teal
	color = Color.from_hsv(hue, sat, val)

@export_color_no_alpha var color = Color("FFFFFF"):
	set(new_value):
		color = new_value
		if meshToChangeColorOf: #safety net 1
			var node = get_node_or_null(meshToChangeColorOf) #safety net 2
			if node: #safety net 3
				node.material_override.albedo_color = color
			else:
				printerr("no mesh has been targeted! whose color am I supposed to change??")
			


@export_node_path("MeshInstance3D") var meshToChangeColorOf

@export var randomColorOnReady : bool = false ##new random color every time the level loads

func _ready():
	##Dont do it in the editor or else we can get github conflits just from opening the scene
	if !Engine.is_editor_hint() and randomColorOnReady:
		setRandColor() 
