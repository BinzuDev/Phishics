@tool
extends Node3D


var length : float = 10

@onready var skinCount := $Skins.get_child_count()



func _ready():
	set_skin_carousel()
	


func set_skin_carousel():
	var i = 0
	var radius = length/2
	for skin in $Skins.get_children():
		i += 1
		var spacing = length / (skinCount+1)
		skin.position.x = (spacing * i) - radius
		
		var x = skin.position.x
		skin.position.z = (sqrt(radius**2 - x**2) - radius)
		#print(skin.position.x)



func _process(delta):
	if Engine.is_editor_hint() and Engine.get_frames_drawn() % 10:
		set_skin_carousel()
