extends Area3D

@export var Enables_jump: bool = false



func _on_body_entered(body: Node3D) -> void:
	if body is player: 
		if Enables_jump: 
			body.canJump = true
			print("can jump")
		if Enables_jump == false:
			body.canJump = false 
			print("can't jump")
 
