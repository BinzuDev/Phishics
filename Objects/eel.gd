extends Node3D

var fish : player
var lockFish : bool = false

static var talkedAlready : bool = false

var camZoom = 52

func _ready():
	$UI.visible = false
	fish = get_tree().get_first_node_in_group("player")
	talkedAlready = false
	

func _process(delta: float) -> void:
	
	#make the scope shader work regardless of window size
	var window_size = get_window().get_size()
	$UI/ColorRect.material.set_shader_parameter("screen_width",  window_size.x)
	$UI/ColorRect.material.set_shader_parameter("screen_height", window_size.y)
	
	
	#Disable the first meeting dialogue on ALL eels
	if talkedAlready and !$firstMeeting/CollisionShape3D.disabled:
		$firstMeeting/CollisionShape3D.disabled = true
		$repeatMeeting/CollisionShape3D.disabled = false
	
	
	
	## When fish is on eel
	if lockFish:
		fish.force_position($eel_sprite/fish_pos.global_position)
		var yAxis = Input.get_axis("right", "left")
		var xAxis = Input.get_axis("back", "forward")
		$cam_anchor.rotation.y += yAxis * delta * %Camera3D.fov * 0.03
		$cam_anchor.rotation.x += xAxis * delta * %Camera3D.fov * 0.03
		$cam_anchor.rotation.x = clamp($cam_anchor.rotation.x, -PI/2, PI/2)
		
		
		if Input.is_action_pressed("confirm"):
			camZoom = clamp(camZoom - 0.5, 22, 52) #from 10.5 to 78.3
		if Input.is_action_pressed("camera"):
			camZoom = clamp(camZoom + 0.5, 22, 52)
		print(camZoom)
		%Camera3D.fov = 5 + pow(camZoom * 0.0805, 3)
		
		
		
		
		if Input.is_action_just_pressed("cancel") and !$AnimationPlayer.is_playing():
			$AnimationPlayer.play("lower_to_floor")
			$cam_anchor/Camera3D.current = false
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
		$cam_anchor/Camera3D.current = true
		fish.visible = false
		fish.process_mode = Node.PROCESS_MODE_DISABLED
		$UI.visible = true
		$eel_sprite/scope.visible = false
		ScoreManager.hide()
		%Camera3D.fov = 60
		print("RESETING THE FOV")
	if anim_name == "lower_to_floor":
		$AnimationPlayer.play("idle")
		lockFish = false
		fish.isHeld = false
