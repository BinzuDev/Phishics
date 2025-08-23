extends Node3D


func _ready():
	pass 

func _process(_delta):
	pass


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
		$AnimationExtras.play("RESET")
	
	
	
