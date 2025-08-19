@icon("res://icons/bowlingPins.png")
extends Node3D
class_name bowlingPins

var touched: bool = false
var fishSpeed

@export var disableHoming : bool = false
@export var floating : bool = false

#static variables are shared across every instance of an object
static var currFrame := 0  
static var pitch := 1.0
static var timeSinceLastStrike := 0


func _process(delta):
	if currFrame != Engine.get_process_frames():
		timeSinceLastStrike += 1
		if timeSinceLastStrike > 200:
			pitch = 1.0
		currFrame = Engine.get_process_frames()
	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$STRIKEsprite.visible = false #make sure its invisible at start
	if disableHoming:
		$Area3D.set_collision_layer_value(6, false) #turns off homing collsion
	if floating:
		for pin in $Pins.get_children(): #set the gravity of all pins to 0 if floating
			pin.gravity_scale = 0.0
			pin.get_node("./model").cast_shadow = false
			



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
			child.gravity_scale = 1.0 #reset gravity if floating
			child.get_node("./model").cast_shadow = true



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is player and not touched:
		
		#confirm touched
		touched = true
		
		#trick
		ScoreManager.give_points(500, 2, true, "STRIKE!")
		ScoreManager.update_freshness(self)
		ScoreManager.play_trick_sfx("rare")
		print("strike!")
		
		fishSpeed = body.linear_velocity.length()
		apply_force_to_rigidbodies() #func for strike
		
		#effects
		$strikeSFX.pitch_scale = pitch
		$strikeSFX.play() #sfx
		pitch += 0.1
		timeSinceLastStrike = 0
		%strikeAnimation.play("STRIKE") #animation
		
		$Area3D.set_collision_layer_value(6, false) #turns off homing collsion
