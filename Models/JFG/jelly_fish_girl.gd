extends Node3D

@export var customEyes : bool = true


func _ready():
	pass 

func _process(_delta):
	%moveIrisRight.visible = customEyes
	%moveIrisLeft.visible = customEyes
	%EyeWhite.visible = customEyes


func play_animation(anim : String):
	if $AnimationPlayer.has_animation(anim):
		$AnimationPlayer.play(anim)
	else:
		$AnimationPlayer.play("T-Pose")
	
	$AnimationExtras.play("RESET")
	$AnimationExtras.advance(0)
	if $AnimationExtras.has_animation(anim):
		$AnimationExtras.play(anim)
	else:
		$AnimationExtras.play("Blinking")
	
	
	
