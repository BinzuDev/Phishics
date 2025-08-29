@tool
@icon("res://icons/warning_sign.png")
extends RigidBody3D
var touched: bool = false

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


func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is player:
		gravity_scale = 4 #when player touches it, it falls
		
		linear_velocity = body.linear_velocity * 1
		angular_velocity = body.angular_velocity * 1
		
		#Switch to folded version if fast enough
		if body.linear_velocity.length() > 10:
			$bend.rotation_degrees.y = -60
			$collisionFlat.set_deferred("disabled", true)
			$collisionBend1.set_deferred("disabled", false)
			$collisionBend2.set_deferred("disabled", false)
		
		
		if not touched: #destruction points
			ScoreManager.give_points(100, 1, false, "VANDALISM")
			ScoreManager.play_trick_sfx("uncommon")
			$AudioStreamPlayer3D.play()
			touched = true
		
