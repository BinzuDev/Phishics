@icon("res://icons/jellyfish.png")
extends PathFollow3D


@export var speed = 5
@export_range(5, 100, 1.0) var bounceForce : int = 25 ##How high the fish will bounce
##How much the fish's horizontal speed will be affected. 
##0: go straight up.  1: keep your speed. 2: double your speed
@export_range(0, 2, 0.1, "suffix:x") var hSpeedMultiplier : float = 0.5



func _process(_delta: float) -> void:
	#makes him move
	progress += speed * _delta 
	


func _on_jellyfish_area_body_entered(body: Node3D) -> void:
	#hopping on jellyfish
	if body is player and !body.diving:
		print("touching jellyfish but not diving!")
	if body is player and body.diving:
		body.linear_velocity.x *= hSpeedMultiplier
		body.linear_velocity.y = bounceForce
		body.linear_velocity.z *= hSpeedMultiplier
		#body.linear_velocity = Vector3.ZERO
		#body.apply_central_impulse(Vector3.UP * 50)
		#TRICK
		print("bounce")
		ScoreManager.give_points(1000, 1, true, "JELLY JUMP")
		ScoreManager.update_freshness(self)
		%AudioJF.play()
