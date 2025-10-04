@icon("res://icons/tornado.png")
class_name tornado
extends Node3D

var timer : int = 0
var fishTouched : bool = false
@export var flipSpd : int = 5



func _process(_delta):
	timer += 1
	if timer >= flipSpd:
		$Sprite3D.flip_h = !$Sprite3D.flip_h
		timer = 0


func _on_area_3d_body_entered(body):
	if body is player and fishTouched == false:
		body.global_rotation_degrees.z = -90
		body.linear_velocity *= 2
		var speed = clamp(body.angular_velocity.length() * 2, 60, 200)
		body.angular_velocity = Vector3(0,speed,0)
		if body.surfMode:
			body.play_skate_anim("tornado")
		$AnimationPlayer.play("spin")
		fishTouched = true
		ScoreManager.give_points(500, 0, true, "TORNADO")
		ScoreManager.update_freshness(self)
		
		
	


func _on_exit_body_exited(_body):
	fishTouched = false
	print("tornado left")
