extends Node3D

var fish : Player
var lockFish : bool = false

static var talkedAlready : bool = false #static allows the var to be shared across instances

var camZoom = 52

var moveSpd : Vector2

func _ready():
	$UI.visible = false
	fish = get_tree().get_first_node_in_group("player")
	talkedAlready = false
	

func _process(delta: float) -> void:
	
	#make the scope shader work regardless of window size
	var window_size = get_window().get_size()
	%scopeShader.material.set_shader_parameter("screen_width",  window_size.x)
	%scopeShader.material.set_shader_parameter("screen_height", window_size.y)
	
	
	#Disable the first meeting dialogue on ALL eels
	if talkedAlready and !$firstMeeting/CollisionShape3D.disabled:
		$firstMeeting/CollisionShape3D.disabled = true
		$repeatMeeting/CollisionShape3D.disabled = false
	
	
	
	## When fish is on eel
	if lockFish:
		fish.force_position($eel_sprite/fish_pos.global_position)
		var yAxis = Input.get_axis("right", "left")
		var xAxis = Input.get_axis("back", "forward")
		
		moveSpd = lerp(moveSpd, Vector2(xAxis,yAxis), 0.2)
		
		$cam_anchor.rotation.y += moveSpd.y * delta * %eelCam.fov * 0.03
		$cam_anchor.rotation.x += moveSpd.x * delta * %eelCam.fov * 0.03
		$cam_anchor.rotation.x = clamp($cam_anchor.rotation.x, -PI/2, PI/2)
		
		
		if Input.is_action_pressed("confirm"):
			camZoom = clamp(camZoom - 0.5, 15, 54) #from 6.7 to 87
		if Input.is_action_pressed("camera"):
			camZoom = clamp(camZoom + 0.5, 15, 54)
		
		%eelCam.fov = 5 + pow(camZoom * 0.0805, 3)
		
		
		## Shader effects
		var transp = (1-%eelCam.fov*0.03) + 1.34
		if %eelCam.fov < 60:
			transp = (1-%eelCam.fov*0.006) - 0.1
		
		var size = %eelCam.fov*0.016 - 0.45
		if %eelCam.fov < 60:
			size = %eelCam.fov*0.001 + 0.45
		
		var fishEye = max(0.05, (1-%eelCam.fov * 0.015) + 0.4 ) 
		
		print("fov: ", %eelCam.fov, " camZoom: ", camZoom, " transps: ", transp, " size: ", size, " fisheye: ", fishEye)
		%scopeShader.material.set_shader_parameter("opacity", transp )
		%scopeShader.material.set_shader_parameter("circle_size", size )
		$UI/fisheye.material.set_shader_parameter("effect_amount", fishEye )
		
		if Input.is_action_just_pressed("cancel") and !$AnimationPlayer.is_playing():
			$AnimationPlayer.play("lower_to_floor")
			%eelCam.current = false
			fish.forceMakeCameraCurrent()
			fish.visible = true
			fish.process_mode = Node.PROCESS_MODE_INHERIT
			$UI.visible = false
			$eel_sprite/scope.visible = true
			ScoreManager.show()
			#scope close sound
			%AudioScopeClose.play()
	


## When textbox is closed
func start_eel_ride():
	lockFish = true
	fish.isHeld = true
	
	#lil scope sound
	%AudioScopeOpen.play()
	
	$AnimationPlayer.play("raise_high")
	ScoreManager.reset_airspin()
	
	talkedAlready = true



func _on_animation_finished(anim_name):
	if anim_name == "raise_high":
		%eelCam.current = true
		fish.visible = false
		fish.process_mode = Node.PROCESS_MODE_DISABLED
		$UI.visible = true
		$eel_sprite/scope.visible = false
		ScoreManager.hide()
		%eelCam.fov = 52.5
		camZoom = 45
		print("RESETING THE FOV")
	if anim_name == "lower_to_floor":
		$AnimationPlayer.play("idle")
		lockFish = false
		fish.isHeld = false
