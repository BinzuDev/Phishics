@icon("res://icons/target.png")
extends Node3D
class_name Target


func _on_homing_hitbox_body_entered(body):
	if body is player and body.diving:
		ScoreManager.give_points(100, 0, true, "BULLSEYE")
