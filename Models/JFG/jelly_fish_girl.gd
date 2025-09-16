extends Node3D

@export var defaultAnimation : String = ""


func _ready():
	if defaultAnimation:
		play_animation(defaultAnimation)
	
	if get_tree().current_scene == self:
		print("Debug mode")
		$DirectionalLight3D.visible = true
		$Platform.visible = true
		play_animation("Hug")
	else:
		$DirectionalLight3D.visible = false
		$Platform.visible = false
	

func _process(_delta):
	pass
	#safety net to make sure her eyes never become cursed
	#if %EyeOverlay.get_instance_shader_parameter("frame") != 0:
	#	%EyeWhite.visible = false
	


func play_animation(anim : String):
	if $AnimationPlayer.has_animation(anim):
		$AnimationPlayer.play(anim)
	else:
		$AnimationPlayer.play("A-Pose")
	
	$AnimationExtras.play("RESET")
	$AnimationExtras.advance(0)
	if $AnimationExtras.has_animation(anim):
		$AnimationExtras.play(anim)
	else:
		$AnimationExtras.play("Blinking")
	
	
	
