@tool
extends Node3D

@export var defaultAnimation : String = ""
@export var animationPreview : bool = false
#@export var hatFaceClipping : float = 5.0


func _ready():
	if !Engine.is_editor_hint(): #if not in the editor
		if defaultAnimation:
			play_animation(defaultAnimation)
			print(get_parent().name, "'s jfg is starting to play ", defaultAnimation)
		else:
			$AnimationPlayer.play("A-Pose")
	else:
		$AnimationPlayer.play("T-Pose")
	
	#$hatFace/HatFaceMesh.set_instance_shader_parameter("cam_distance", hatFaceClipping)
	if get_tree().current_scene == self:
		print("JFG is in a her own scene")
		$DirectionalLight3D.visible = true
		$Platform.visible = true
		if process_mode != Node.PROCESS_MODE_DISABLED: 
			play_animation("Cheering")
	else:
		print("JFG is in a different scene")
		$DirectionalLight3D.visible = false
		$Platform.visible = false
		animationPreview = false
	

func _process(_delta):
	if Engine.is_editor_hint() and animationPreview:
		$AnimationPlayer.play("Cheering")
		$AnimationPlayer.seek($AnimationExtras.current_animation_position, true)
		
	


func play_animation(anim : String):
	if $AnimationPlayer.has_animation(anim):
		$AnimationPlayer.play(anim)
	else:
		$AnimationPlayer.play("A-Pose")  #default to A pose as a backup
	
	##Dont reset animation is current animation is already the right one
	if $AnimationExtras.is_playing() and $AnimationExtras.current_animation == anim:
		return
	
	$AnimationExtras.play("RESET") #play reset for 1 frame to reset everything
	$AnimationExtras.advance(0)
	if $AnimationExtras.has_animation(anim):
		$AnimationExtras.play(anim)
	else:
		$AnimationExtras.play("Blinking") #default to blinking as a backup
	
	

##if you want an aniation to transition into a looping version
##NOTE: THIS IS CALLED WHEN ANIMATION *EXTRA* IS DONE 
func _on_animation_finished(anim_name):
	if !Engine.is_editor_hint():
		if anim_name == "tuto_hello":
			$AnimationPlayer.play("tuto_hello_end")
			$AnimationExtras.play("Blinking")
		if anim_name == "YouCanDoIt":
			$AnimationPlayer.play("YouCanDoIt_end")
			$AnimationExtras.play("YouCanDoIt_end")
