extends PathFollow3D

var isRailgrinding: bool = false

var fish: player

var timer = 0

func _ready():
	fish = get_tree().get_first_node_in_group("player")

func _process(_delta):
	if fish and get_parent() is Path3D:
		var path_3d = get_parent() as Path3D
		var curve = path_3d.curve
		
		var target_position = path_3d.to_local(fish.global_position)
		var closest_offset = curve.get_closest_offset(target_position) #makes the hitbox follow the fish
		
		self.progress = closest_offset
	
	#unmount
	if Input.is_action_just_pressed("jump") and isRailgrinding:
		fish.reparent(get_tree().get_current_scene())
		fish.linear_velocity = Vector3(0,0,0)
		fish.apply_impulse(Vector3(0,20,0))  #jump off
		isRailgrinding = false
		
	if isRailgrinding:
		timer = 0
	else :
		timer += 1

func _on_area_entered(body):
	
	if timer > 60:
		isRailgrinding = true
		body.reparent(self)
