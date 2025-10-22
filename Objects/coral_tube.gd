@tool
extends Node3D
#var touched = false

@export_color_no_alpha var color = Color("FFFFFF"):
	set(new_value):
		color = new_value
		$corals/coral/model.material_override.albedo_color = color
		



#func _coral_spread():
	#for child in $corals.get_children():
		#if child is RigidBody3D:
			#child.set_collision_mask_value(1, true)#enables collison with the world so we can plant it in sand
			#child.gravity_scale = 1



func _on_area_3d_body_entered(body: Node3D) -> void:
	#if body is player and not touched:
		#_coral_spread()
		#touched = true
		#
		##trick
		#ScoreManager.give_points(200, 1, true, "DESTRUCTION")
		#ScoreManager.update_freshness(self)
		#ScoreManager.play_trick_sfx("uncommon")
		$corals/AnimationPlayer.play("coral_wiggle")
		
