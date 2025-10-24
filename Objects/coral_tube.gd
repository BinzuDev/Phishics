@icon("res://icons/tubeCoral.png")
@tool
extends Node3D
class_name coral_tube
#var touched = false

@export_color_no_alpha var color = Color("FFFFFF"):
	set(new_value):
		color = new_value
		$corals/coral/model.material_override.albedo_color = color
		

@export_tool_button("Generate random color") var action = setRandColor
func setRandColor():
	var hue = randf_range(0.0, 1.0)
	var sat = 0.5
	##Because of the world environment, it makes reds way LESS saturated
	##and teals way MORE saturated, so I have to compensate here
	if (hue > 0.133 and hue < 0.833): #less saturated when blue-green
		sat = 0.4
	else: #more saturated when red
		sat = 0.6
	sat += randf_range(-0.08, 0.08) #extra randomness
	var val = 1.0
	if (hue > 0.45 and hue < 0.547):
		val = 0.85 #darker when perfectly teal
	color = Color.from_hsv(hue, sat, val)






func _coral_spread():
	#for child in $corals.get_children():
		#if child is RigidBody3D:
			#child.set_collision_mask_value(1, true)#enables collison with the world so we can plant it in sand
			#child.gravity_scale = 1
	queue_free()
	print("TUBE CORAL SPREAD FUNC")



func _on_area_3d_body_entered(body: Node3D) -> void:
	#if body is Mine:
		#_coral_spread()
		
		##trick
		#ScoreManager.give_points(200, 1, true, "DESTRUCTION")
		#ScoreManager.update_freshness(self)
		#ScoreManager.play_trick_sfx("uncommon")
		
		
		
	if body is player:
		$corals/AnimationPlayer.play("coral_wiggle") #animation
		$AudioStreamPlayer3D.play()
		
