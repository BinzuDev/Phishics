@tool
@icon("res://Icons/coral_tube.png")
class_name CoralTube extends Coral



func coral_spread():
	#for child in $corals.get_children():
		#if child is RigidBody3D:
			#child.set_collision_mask_value(1, true)#enables collison with the world so we can plant it in sand
			#child.gravity_scale = 1
	#queue_free()
	#position.y -= 1
	print("TUBE CORAL SPREAD FUNC")



func _on_area_3d_body_entered(body: Node3D) -> void:
	#if body is Mine:
		#_coral_spread()
		
		##trick
		#ScoreManager.give_points(200, 1, true, "DESTRUCTION")
		#ScoreManager.update_freshness(self)
		#ScoreManager.play_trick_sfx("uncommon")
		
		
		
	if body is Player:
		$corals/AnimationPlayer.play("coral_wiggle") #animation
		$AudioStreamPlayer3D.play()
		
