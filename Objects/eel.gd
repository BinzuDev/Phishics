extends Node3D

var fish : player
var lockFish : bool = false

func _ready():
	$Label3D.visible = false
	$UI.visible = false
	

func _process(delta: float) -> void:
	
	#make the scope shader work regardless of window size
	var window_size = get_window().get_size()
	$UI/ColorRect.material.set_shader_parameter("screen_width",  window_size.x)
	$UI/ColorRect.material.set_shader_parameter("screen_height", window_size.y)
	
	
	
	if !$appear.has_overlapping_bodies():
		$Label3D.visible = false
	else:
		$Label3D.visible = true
		## When confirmed pressed inside the area
		if Input.is_action_just_pressed("confirm"):
			lockFish = true
			fish.isHeld = true
			
			#lil scope sound
			%AudioScopeOpen.play()
			
			$AnimationPlayer.play("raise_high")
			ScoreManager.reset_airspin()
			
	
	
	## When fish is on eel
	if lockFish:
		fish.force_position($eel_sprite/fish_pos.global_position)
		var yAxis = Input.get_axis("right", "left")
		var xAxis = Input.get_axis("back", "forward")
		$cam_anchor.rotation.y += yAxis * delta * %Camera3D.fov * 0.03
		$cam_anchor.rotation.x += xAxis * delta * %Camera3D.fov * 0.03
		$cam_anchor.rotation.x = clamp($cam_anchor.rotation.x, -PI/2, PI/2)
		
		if Input.is_action_pressed("confirm"):
			%Camera3D.fov -= 1
		if Input.is_action_pressed("camera"):
			%Camera3D.fov += 1
		%Camera3D.fov = clamp(%Camera3D.fov, 10, 60)
		
		
		if Input.is_action_just_pressed("cancel"):
			$AnimationPlayer.play("lower_to_floor")
			$cam_anchor/Camera3D.current = false
			fish.visible = true
			fish.process_mode = Node.PROCESS_MODE_INHERIT
			$UI.visible = false
			$eel_sprite/scope.visible = true
			ScoreManager.show()
			#scope close sound
			%AudioScopeClose.play()
	


func _on_area_eel_body_entered(body: Node3D) -> void:
	if body is player:
		fish = body

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
