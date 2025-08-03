extends Node3D

var coolDown = 0
var stopSlowmo : bool = false
var animTimer : int = 0
var dunkedObj


func _physics_process(_delta: float) -> void:
	coolDown += 1
	
	#if $dontResetCombo.has_overlapping_bodies():
		#var fish = $dontResetCombo.get_overlapping_bodies()
		#fish[0].give_points(0,0,true) #resets the timer
		##fish[0].comboTimer += 2 #give you extra time
	#else:
		#%hoopCollision.collision_layer = 1 #reaply collision once fish leaves
		#stopSlowmo = false
	
	## Delayed Dive dunk
	if coolDown == -1:
		perform_dunk(dunkedObj)
	
	
	## Slowmo
	if $slowmo.has_overlapping_bodies() and stopSlowmo == false:
		var fish = $slowmo.get_overlapping_bodies()
		var distance = (fish[0].global_position - global_position).length() * 0.5
		Engine.time_scale = clamp(distance-0.15, 0.1, 1) #slowmo
		var pitch = AudioServer.get_bus_effect(4,0)
		pitch.pitch_scale = clamp(distance*0.5 +0.4, 0.5, 1) #music slow down
		
		var zoom = 80 - (25 - clamp(distance*25, 0, 25) )
		get_tree().get_first_node_in_group("camera").fov = zoom
		#print("distance: ", distance, " pitch: ", pitch.pitch_scale)
		
		
		
	
	## Animation
	animTimer += 1
	for nodes in $hoopString.get_children():
		nodes.rotation_degrees.y = sin(animTimer*0.1) * 5
	
	## Debug text
	$Label3D.text = str("stopSlowmo: ", stopSlowmo, "
	slowmo.overlapping: ", $slowmo.has_overlapping_bodies(), "
	resetHoop.overlapping: ", $resetHoop.has_overlapping_bodies(), "
	DunkArea.overlapping: ", $DunkArea.has_overlapping_bodies(), "
	cooldown: ", coolDown)
	
	

## On successful dunking
func _on_body_entered(body: Node3D) -> void:
	print(body.name, " HAS ENTERED THE DUNKING AREA")
	#get_tree().paused = !get_tree().paused
	
	if body is enemy:
		ScoreManager.give_points(99999, 0, true, "CRAB DUNK")
		ScoreManager.play_trick_sfx("legendary") 
		body.apply_central_impulse(Vector3(0, -10, 0))
	
	stopSlowmo = true
	if body is player and coolDown > 60: 
			#$dunkList.text += str("\nENTERING AGAIN DURING COOLDOWN")
			#print("ENTERING AGAIN DURING COOLDOWN")
		#else:
			#if body.linear_velocity.y >= 0: 
				#print("IN THEORY, THE PLAYER SHOULD BE GOING UPWARDS RN, AND THUS, DUNK DOESNT COUNT")
				#$dunkList.text += str("\nBAD DUNK \n spd: ", body.linear_velocity.y  )
				#print("spd: ", body.linear_velocity.y)
			#else:
		$dunkList.text += str("\nSUCCESSFUL DUNK \n spd: ", body.linear_velocity.y  )
		print("SUCCESSFUL DUNK spd: ", body.linear_velocity.y)
		#Diffrenciates between dunks
		
		ScoreManager.comboTimer += 80 #give you extra time
		#print("Applying central impusle to ", body.name)
		body.apply_central_impulse(Vector3(0, -10, 0))
		
		coolDown = 0
		if body.diving:
			GameManager.hitstop(10, self)
			coolDown = -3
			dunkedObj = body
			body.rotation_degrees = Vector3(0,90,90)
			##If you're diving, it'll perfom the dunk in func process
			##As soon as the freezeframe is over
		else:
			perform_dunk(body)
		
		
	
	

func perform_dunk(body):
	if body.linear_velocity.y < -15:
		if body.diving:
			ScoreManager.give_points(4000, 10, true, "DIVING DUNK")
		else:
			ScoreManager.give_points(8000, 30, true, "KOBE")
		ScoreManager.play_trick_sfx("legendary") 
	elif body.linear_velocity.y < -10:
		ScoreManager.give_points(2000, 10, true, "BIG DUNK")
		ScoreManager.play_trick_sfx("rare")
	else:
		ScoreManager.give_points(1000, 5, true, "SLAM DUNK")
	
	$ScoreSound.play() #dunk sfx
	$HoopPuff.emitting = true #Particles 
	%hoopCollision.collision_layer = 0 #disable collision so fish passes through
	$antiCheese.collision_layer = 0
	Engine.time_scale = 1
	


func _on_slowmo_body_entered(body: Node3D) -> void:
	if body.process_mode == Node.PROCESS_MODE_INHERIT:
		print(body.name, " HAS ENTERED THE SLOMO AREA")
		if body is player:
			$Slomo.play() #sound for starting slowmo


func _on_slowmo_body_exited(body):
	if body.process_mode == Node.PROCESS_MODE_INHERIT:
		print(body.name, " HAS EXITED THE SLOMO AREA")
		if body is player:
			Engine.time_scale = 1
			var pitch = AudioServer.get_bus_effect(4,0)
			pitch.pitch_scale = 1
			$SlomoEnd.play()


func _on_reset_hoop_body_exited(body):
	if body.process_mode == Node.PROCESS_MODE_INHERIT:
		print(body.name, " HAS EXITED THE RESET HOOP AREA")
		%hoopCollision.collision_layer = 1 #reaply collision once fish leaves
		$antiCheese.collision_layer = 4
		stopSlowmo = false
