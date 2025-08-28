extends Node3D

@export var customEyes : bool = true


func _ready():
	#$DirectionalLight3D.visible = false
	#$Platform.visible = false
	play_animation("Hug")
	

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
	
	
	
