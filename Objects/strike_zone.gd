@icon("res://icons/bowlingPins.png")
extends Node3D
var touched: bool = false
var fishSpeed

@export var disableHoming : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$STRIKEsprite.visible = false #make sure its invisible at start
	if disableHoming:
		$Area3D.set_collision_layer_value(6, false) #turns off homing collsion



func apply_force_to_rigidbodies():
	var node_center = $Pins.global_transform.origin #get center of node
	var force_range = fishSpeed * 0.1
	var node_3d = $Pins #store node
	for child in node_3d.get_children(): #get children of node from earlier
		if child is RigidBody3D:
			var direction = child.global_transform.origin - node_center
			child.apply_central_impulse(direction.normalized() * force_range) #apply force opposite of the center
			var randSpin = Vector3(randf_range(-1.0, 1.0),randf_range(-0.5, 0.5),randf_range(-3.0, 3.0))
			child.apply_torque_impulse(randSpin)



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is player and not touched:
		
		#confirm touched
		touched = true
		
		#trick
		ScoreManager.give_points(500, 2, true, "STRIKE!", "rare", false)
		ScoreManager.play_trick_sfx("rare")
		print("strike!")
		
		fishSpeed = body.linear_velocity.length()
		apply_force_to_rigidbodies() #func for strike
		
		#effects
		$strikeSFX.play() #sfx
		%strikeAnimation.play("STRIKE") #animation
		
		$Area3D.set_collision_layer_value(6, false) #turns off homing collsion
