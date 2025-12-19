extends Area3D


func _process(_delta: float) -> void:
	rotation.x += 0.02


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.checkpoint_pos = global_position
		print("Checkpoint touched at:", body.checkpoint_pos)
	
