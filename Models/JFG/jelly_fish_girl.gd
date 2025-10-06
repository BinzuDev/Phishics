@tool
extends Node3D

@export var defaultAnimation : String = ""
@export var animationPreview : bool = false


func _ready():
	if !Engine.is_editor_hint(): #if not in the editor
		if defaultAnimation:
			play_animation(defaultAnimation)
			print(get_parent().name, "'s jfg is starting to play ", defaultAnimation)
		
	if get_tree().current_scene == self:
		print("Debug mode")
		$DirectionalLight3D.visible = true
		$Platform.visible = true
		var list = "string"
		list.length()
		play_animation("Cheering")
	else:
		$DirectionalLight3D.visible = false
		$Platform.visible = false
	

func _process(_delta):
	if Engine.is_editor_hint() and animationPreview:
		$AnimationPlayer.play("tuto_think")
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
	
	
