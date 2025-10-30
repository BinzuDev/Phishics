@tool
extends Node3D
class_name flat_coral

@export_color_no_alpha var color = Color("FFFFFF"):
	set(new_value):
		color = new_value
		$StaticBody3D/flatcoralMesh.albedo_color = color
		

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
