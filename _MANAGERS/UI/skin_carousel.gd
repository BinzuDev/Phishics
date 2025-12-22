@tool
extends Node3D

@export var database: Database

@export var fakeFish: PackedScene 

@export var length : float = 50

@onready var skinCount := $Skins.get_child_count()



func _ready():
	set_skin_carousel()
	#set_fake_fish()



func set_fake_fish():
	for skin_data in database.skins:
		var fakeFishInstaniated = fakeFish.instantiate()
		$Skins.add_child(fakeFishInstaniated)
		
		
		for child in fakeFishInstaniated.get_children():
			if child is Sprite3D:
				child.texture = skin_data.skin
				





func set_skin_carousel():
	var i = 0
	var radius = length/2
	for skin in $Skins.get_children():
		i += 1
		var spacing = length / (skinCount+1)
		skin.position.x = (spacing * i) - radius
		
		var x = skin.position.x
		skin.position.z = (sqrt(radius**2 - x**2) - radius)*2
		#print(skin.position.x)



func _process(delta):
	if Engine.is_editor_hint() and Engine.get_frames_drawn() % 10 == 0:
		print("update")
		set_skin_carousel()
