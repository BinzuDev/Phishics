@tool
@icon("res://icons/warning_sign.png")
class_name sign
extends RigidBody3D

var fellOff: bool = false
var bent: bool = false
var fileName : String = ""
var originalPos : Vector3
var originalAng : Vector3

#####################################
## SIGN SPRITE NAMING CHEAT SHEET
## starts with tri_: sprite gets lowered 50 pixels
## starts with long_: the sprite gets rotated when used as a surf board, right=forward


#allows us to switch sprites
@export_file("*.png") var signSprite: String = "res://Sprites/signs/tri_fishwarning.png": 
	set(new_value):
		signSprite = new_value
		if Engine.is_editor_hint():
			if get_node_or_null("./spriteL"): #failsafe check to prevent errors
				set_sign_visuals()

@export var canRespawn : bool = false

func _ready() -> void:
	if !Engine.is_editor_hint():
		originalPos = global_position
		originalAng = global_rotation
		if signSprite.get_file(): #failsafe check to prevent errors
			set_sign_visuals()



func set_sign_visuals():
	$spriteL.texture = load(signSprite)
	$bend/spriteR.texture = load(signSprite)
	
	var id = ResourceUID.text_to_id(signSprite) ##TODO: theres a better way to do this in 4.5
	fileName = ResourceUID.get_id_path(id)
	$spriteL.position.y = 0
	$bend.position.y = 0
	if fileName.get_file().begins_with("tri_"):
		$spriteL.position.y = -0.25
		$bend.position.y = -0.25
	




func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is player:
		
		gravity_scale = 3 #when player touches it, it falls
		angular_velocity = body.angular_velocity
		linear_velocity = body.linear_velocity
		
		if not fellOff: #destruction points
			if !fileName.get_file().contains("skateBoard"): #stealing isnt vandalism technically?
				ScoreManager.give_points(2500, 1, true, "VANDALISM")
				ScoreManager.play_trick_sfx("uncommon")
			$collisionFlat.set_deferred("disabled", false)
			$AudioStreamPlayer3D.play()
			fellOff = true
			$Timer.start()
		
		#if the fish isnt surfing and the sign isnt bent yet
		if body.surfMode == false and not bent:
			ScoreManager.update_freshness(self)
			if fileName.get_file().contains("skateBoard"):
				body.skateboardSurf = true
			body.activateSurfMode(fileName, self)
			$collisionFlat.set_deferred("disabled", true)
			$Area3D.set_deferred("monitoring", false)
			set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
			visible = false
		
		


func throwAway():
	if canRespawn:
		fellOff = false
		visible = true
		gravity_scale = 0
		global_position = originalPos
		global_rotation = originalAng
		angular_velocity = Vector3.ZERO
		linear_velocity = Vector3.ZERO
		await get_tree().create_timer(0.1).timeout
		$collisionFlat.set_deferred("disabled", false)
		$Area3D.set_deferred("monitoring", true)
		set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	else:
		visible = true
		set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
		gravity_scale = 3 #when player touches it, it falls
		$bend.rotation_degrees.y = -60
		apply_central_impulse(Vector3(0,-6,0))
		$AudioStreamPlayer3D.play()
		bent = true
		if fileName.get_file().contains("skateBoard"): #special trick when breaking skateboard
			ScoreManager.give_points(10000, 0, true, "NEUTRON STYLE")
		$Area3D.set_collision_layer_value(6, false) #turn off homing when bent
		#temporarily turn off collision as you jump off
		set_collision_layer_value(3, false) 
		await get_tree().create_timer(0.05).timeout
		$collisionBend1.set_deferred("disabled", false)
		$collisionBend2.set_deferred("disabled", false)
		set_collision_layer_value(3, true)  #turn it back on after 6 frames
		$Area3D.set_deferred("monitoring", true)
	


func _on_timer_timeout():
	if canRespawn:
		throwAway()
