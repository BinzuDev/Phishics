@tool
@icon("res://icons/warning_sign.png")
extends RigidBody3D

var fellOff: bool = false
var bent: bool = false

#allows us to switch sprites
@export_file("*.png") var signSprite: String = "res://Sprites/signs/warning_sign.png": 
	set(new_value):
		signSprite = new_value
		if Engine.is_editor_hint():
			if get_node_or_null("./Sprite3D"): #failsafe check to prevent errors
				$Sprite3D.texture = load(new_value) #changes sprites real time
				$bend/Sprite3D2.texture = load(new_value)


func _ready() -> void:
	if !Engine.is_editor_hint():
		if signSprite.get_file(): #failsafe check to prevent errors
			$Sprite3D.texture = load(signSprite)
			$bend/Sprite3D2.texture = load(signSprite)


func _process(_delta: float) -> void:
	pass
	


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is player:
		
		angular_velocity = body.angular_velocity
		linear_velocity = body.linear_velocity
		
		
		if not fellOff: #destruction points
			ScoreManager.give_points(2500, 1, true, "VANDALISM")
			ScoreManager.play_trick_sfx("uncommon")
			$AudioStreamPlayer3D.play()
			fellOff = true
		
		
		#if the fish isnt surfing and the sign isnt bent yet
		if body.surfMode == false and not bent:
			body.activateSurfMode(signSprite, self)
			$collisionFlat.set_deferred("disabled", true)
			$Area3D.set_deferred("monitoring", false)
			set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
			visible = false
		
		
		
		
		


func throwAway():
	visible = true
	set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	gravity_scale = 3 #when player touches it, it falls
	$bend.rotation_degrees.y = -60
	apply_central_impulse(Vector3(0,-6,0))
	$AudioStreamPlayer3D.play()
	bent = true
	$Area3D.set_collision_layer_value(6, false) #turn off homing when bent
	#temporarily turn off collision as you jump off
	set_collision_layer_value(3, false) 
	await get_tree().create_timer(0.1).timeout
	$collisionBend1.set_deferred("disabled", false)
	$collisionBend2.set_deferred("disabled", false)
	set_collision_layer_value(3, true)  #turn it back on after 6 frames
	$Area3D.set_deferred("monitoring", true)
	
