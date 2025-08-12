extends Node3D
var touched: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$STRIKEsprite.visible = false #make sure its invisable at start


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func apply_force_to_rigidbodies():
	var node_center = $Pins.global_transform.origin #get center of node
	var force_range = 1.1
	var node_3d = $Pins #store node
	for child in node_3d.get_children(): #get children of node from earlier
		if child is RigidBody3D:
				var direction = child.global_transform.origin - node_center
				child.apply_central_impulse(direction.normalized() * force_range) #apply force opposite of the center



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is player and not touched:
		
		#confirm touched
		touched = true
		
		#trick
		ScoreManager.give_points(500, 2, true, "STRIKE!", "rare", false)
		ScoreManager.play_trick_sfx("rare")
		print("strike!")
		
		apply_force_to_rigidbodies() #func for strike
		
		#effects
		$strikeSFX.play() #sfx
		%strikeAnimation.play("STRIKE") #animation
		
		$Area3D.set_collision_layer_value(6, false) #turns off homing collsion
