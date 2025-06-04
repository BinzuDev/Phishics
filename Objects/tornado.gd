@icon("res://icons/tornado.png")
class_name tornado
extends Node3D

var timer : int = 0

func _process(_delta):
	timer += 1
	if timer == 5:
		$Sprite3D.flip_h = !$Sprite3D.flip_h
		timer = 0


func _on_area_3d_body_entered(body):
	if body is player:
		body.angular_velocity *= 5 
		var x = clamp(body.angular_velocity.x, -999, 999)
		var y = clamp(body.angular_velocity.y, -999, 999)
		var z = clamp(body.angular_velocity.z, -999, 999)
		body.angular_velocity = Vector3(x,y,z)
	
