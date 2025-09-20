@icon("res://icons/fish.png")
class_name player 
extends RigidBody3D

#jump check
@export var canJump: bool = true
@export var noScoreUI : bool = false

var checkpoint_pos: Vector3

#camera
var targetCamAngle: Vector3
var targetCamOffset : Vector3
var targetCamDist: float
var camSpeed: float = 0.2
var cameraOverride: bool = false
var homingLookDown : bool = false ##used to make the cam tilt down when chaining homing dives

#other trick variables
var tiplanding : bool = false
var tipLandAntiCheese : int = 0
var isHeld : bool = false
var isTipSpinning : bool = false
var wallGrind : int = 0
var superJumpTimer : int = -1
var height : float = 0 ##stores how for away you are to the nearest floor
var fishCooldown : int = 0
var diving := false
var homing := false
var timeSinceNoTargets := 0 ##keeps track of how many frames in a row has the homing area has been empty
var posLastFrame = Vector3(0,0,0)
var closestLastFrame = null

#Surfing variables
var surfMode : bool = false
var surfSignRef : Node
var surfJumpHolding : int = 0 #keeps track of how long youve held jump
var inputHistory : Array = ["","",""]
var timeSinceLastInput : int = 0
var surfState : String = ""
var surfRotationType : String = ""
var hasSurfedBefore : bool = false
var isHalfPiping : bool = false
var spinBoostBonus : float = 1.0 #temporary boost of spin speed after inputing a combo


#MOVEMENT CONSTS
const torque_impulse = Vector3(-1.5, 0, 0) #front-back rotation speed
const torque_side = Vector3(0, 0, 1.5)     #left-right rotation speed
const JUMP_STRENGTH = Vector3(0, 9, 0)     #jump strength                                                      
const ACCEL : float = 1.5                  #acceleration speed
const SURFACCEL : float = 3                #surf acceleration speed

#TIMING VARS
var timeSinceJump : int = 0
var flopTimer : int = 0
var sfxCoolDown : int = 0

var noclip := false


func _ready() -> void:
	checkpoint_pos = position
	ScoreManager.fish = self
	%speedLinesShader.material.set_shader_parameter("clipPosition", 0.7)
	$Decal.visible = false
	$surfPivot.visible = false
	if noScoreUI:
		ScoreManager.hide()
	

func _physics_process(_delta: float) -> void:
	
	var accel = ACCEL
	if surfMode:
		accel = SURFACCEL
	
	## Movement
	if Input.is_action_just_pressed("forward"):
		apply_torque_impulse(rotate_by_cam(torque_impulse))
		apply_impulse(rotate_by_cam(Vector3(0, 0, -accel)))
	
	if Input.is_action_just_pressed("back"):
		apply_torque_impulse(rotate_by_cam(torque_impulse * -1))
		apply_impulse(rotate_by_cam(Vector3(0, 0, accel)))
	
	if Input.is_action_just_pressed("right"):
		apply_torque_impulse(rotate_by_cam(torque_side * -1))
		apply_impulse(rotate_by_cam(Vector3(accel, 0, 0)))
	 
	if Input.is_action_just_pressed("left"):
		apply_torque_impulse(rotate_by_cam(torque_side))
		apply_impulse(rotate_by_cam(Vector3(-accel, 0, 0)))
	
	
		###############
		##  Jumping  ##
	timeSinceJump += 1 #so you cant jump twice in a row when spamming
	if Input.is_action_just_pressed("jump") and canJump:
		if !%nearFloor.is_colliding() and surfMode:
			pass #Disable walljumps in surf mode
		elif (timeSinceJump > 20 and %floorDetection.is_colliding()) or noclip:
			timeSinceJump = 0
			#audio
			$Jumps.play()
			$Soft_Impact.play()
			
			#jump Particle
			$JumpPuff.restart()
			$JumpPuff.emitting = true
			
			#apply vertical speed
			apply_impulse(JUMP_STRENGTH)
			if !get_input_axis():
				apply_torque_impulse(rotate_by_cam(torque_impulse)) #flop forward
			
			#mid Air extra control
			var boost = (ACCEL * 3) + clamp(angular_velocity.length()*0.15, 0, 20)
			
			print("long jump boost: 4.5 + ", clamp(angular_velocity.length()*0.15, 0, 20), " = ", boost)
			
			if Input.is_action_pressed("forward"):
				apply_torque_impulse(rotate_by_cam(torque_impulse))
				apply_impulse(rotate_by_cam(Vector3(0, 0, -boost))) #extra acceleration
			if Input.is_action_pressed("back"):
				apply_torque_impulse(rotate_by_cam(torque_impulse * -1))
				apply_impulse(rotate_by_cam(Vector3(0, 0, boost)))
			if Input.is_action_pressed("right"):
				apply_torque_impulse(rotate_by_cam(torque_side * -1))
				apply_impulse(rotate_by_cam(Vector3(boost, 0, 0)))
			if Input.is_action_pressed("left"):
				apply_torque_impulse(rotate_by_cam(torque_side))
				apply_impulse(rotate_by_cam(Vector3(-boost,0, 0)))
				
			if get_input_axis(): #if one of the keys are pressed (long jump)
				apply_impulse(rotate_by_cam(Vector3(0, boost*0.2, 0)))
			
			## Style Meter and jump related tricks
			superJumpTimer = 5 #check your speed 5 frames after jumping
			
			if is_in_air() and %nearFloor.is_colliding():
				ScoreManager.give_points(1000,0, true, "POGO JUMP", "uncommon")
				#play_trick_sfx("uncommon")
			
			if !%nearFloor.is_colliding():
				ScoreManager.give_points(800,1, true, "WALL JUMP", "uncommon")
				ScoreManager.reset_airspin()
				print("Airspin reset by walljump")
				#play_trick_sfx("uncommon")
			
			
			if !get_input_axis(): #High Jump
				var xtraYspd = clamp(angular_velocity.length()*0.35, 0, 35)
				
				apply_impulse(rotate_by_cam(Vector3(0, xtraYspd, 0)))
				
				print("high jump! spd: ", linear_velocity.length(), " xtra: ", xtraYspd )
				
				if linear_velocity.length() > 12: #Points
					ScoreManager.give_points(500, 1, true, "HIGH JUMP", "uncommon")
			else:
				var hspeed = linear_velocity #get your speed
				hspeed.y = 0  #remove your vertical speed from the equation
				hspeed = hspeed.length() #get your true horziontal speed 
				#print("LONG JUMP, speed: ", hspeed)
				if linear_velocity.length() > 12:
					ScoreManager.give_points(200, 1, true, "LONG JUMP", "uncommon")
				
	
	## Super Jump tricks
	if superJumpTimer >= 0:
		superJumpTimer -= 1
	if superJumpTimer == 0:
		#print("super jump:  v: ", linear_velocity.y)
		if linear_velocity.y > 25:
			ScoreManager.give_points(5000, 5, true, "VERTICAL JUMP")
			ScoreManager.comboTimer += 80 #give you extra time
			ScoreManager.play_trick_sfx("legendary")
		
	
	## Surf Jump
	if Input.is_action_pressed("jump"):
		surfJumpHolding += 1
		if surfJumpHolding >= 20 and surfMode:
			deactivateSurfMode()
			ScoreManager.give_points(0, 8, true, "SURF JUMP")
			apply_impulse(JUMP_STRENGTH*5)
	else:
		surfJumpHolding = 0
	
	%surfJumpMeter.visible = surfMode# and surfJumpHolding != 0
	%surfJumpMeter.value = surfJumpHolding
	if hasSurfedBefore:
		%surfJumpMeter.tint_under.a = 0
		%surfJumpMeter.modulate.a = clamp((surfJumpHolding * 0.25) - 1, 0, 1)
	
	var closest = null
	## HOMING ATTACK
	if $homing/area.has_overlapping_areas() and !%nearFloor.is_colliding() and !isHeld:
		closest = get_closest_target()
		if closest != null:
			if closestLastFrame != closest:
				closestLastFrame = closest
				if !$reticle.visible: #only play the animation when it first appears
					$reticle/reticleAnimation.play("reticle_appear1")
					$reticle/sfx.play()
			$reticle.position = get_viewport().get_camera_3d().unproject_position(closest.global_transform.origin)
			$reticle.rotation_degrees += 3
			var newScale = sin(flopTimer*0.157) * 0.15 + 1
			$reticle.scale = Vector2(newScale, newScale)
			$reticle.visible = true
			$reticle.position.y = clamp($reticle.position.y, 0, 1080)
			$reticle.position.x = clamp($reticle.position.x, 0, 1920)
			if $reticle.position.y >= 1000 and homing:
				homingLookDown = true
		else:
			$reticle.visible = false
			closestLastFrame = null
	else:
		$reticle.visible = false
		closestLastFrame = null
	
	if GameManager.hideUI:
		$reticle.modulate.a = 0
		%speedLinesShader.visible = false
	else:
		$reticle.modulate.a = 1
		%speedLinesShader.visible = true
	
	if !$homing/area.has_overlapping_areas() or height < 3:
		timeSinceNoTargets += 1
	else:
		timeSinceNoTargets = 0 
	if timeSinceNoTargets > 15 or isHeld:
		homingLookDown = false
	
	
	## Diving
	if %heightDetect.is_colliding():
		height = global_position.y - %heightDetect.get_collision_point().y
		
	if Input.is_action_just_pressed("dive") and !%nearFloor.is_colliding() and !isHeld:
		var newSpd = clamp(height*-1.5 -10, -90, -10) 
		linear_velocity.y = min(newSpd, linear_velocity.y)
		linear_velocity.x *= 0.5
		linear_velocity.z *= 0.5
		#print("height: ", height, " speed: ", newSpd, " points: ", 100*height )
		ScoreManager.give_points(100*height, 0, false, "DIVE")
		if height > 10:
			ScoreManager.give_points(0, 0, true) #only reset the timer if you're high up enough
			ScoreManager.play_trick_sfx("rare")
		if newSpd <= -75:
			ScoreManager.give_points(0, 10, true, "HIGH DIVE") #diving at capped height
			ScoreManager.play_trick_sfx("legendary")
		print("the transparency is ", %speedLines1.transparency)
		if %speedLines1.transparency < 0.8:
			print("yupp goodneough for me")
			global_rotation = Vector3(0,0,-90)
		diving = true #DIVING VARIABLE
		
		
		
		if closest != null: #Homing attack
			var direction = global_position.direction_to(closest.global_position)
			if closest.get_parent() is enemy:
				closest.get_parent().gravity_scale = 0   #makes it easier to attack falling crabs
				closest.get_parent().linear_velocity = Vector3(0,0,0)
			linear_velocity = direction * 80
			$homing/smear.look_at(closest.global_position)
			$homing/smear.rotation *= -1
			print("look at enemy: ", $homing/smear.rotation_degrees)
			#stupid hacky solution, ask binzu about it if you dont understand
			var diff = abs($homing/smear/leftSide.global_position.x - $homing/smear/rightSide.global_position.x)
			#print(diff)
			if diff < 0.7:
				$homing/smear.rotation_degrees.z = 90
				#print("SMEAR FIX")
			homing = true
			$diveSFX.play()
			if surfMode:
				deactivateSurfMode()
	
	
	#if get_contact_count() >= 1 and linear_velocity.y <= -5:
	#	if diving or homing:
	#		printerr("DIVING WOULD HAVE GOTTEN RESET BEFORE")
	if linear_velocity.y > -5: #otherwise dive can persist if you bounce 
		if diving or homing:
			print("RESETING DIVING")
		diving = false
		homing = false
		
	
	#x0 when homing, x1 otherwise
	if !homing or linear_velocity.y > -25:
		gravity_scale = 1.5
	else:
		gravity_scale = 0.0
	#gravity_scale = !int(homing)
	
	
	##Speed smear
	if homing: 
		$homing/smear.visible = true
		var smearLength = global_position.distance_to(posLastFrame)
		#print(smearLength)
		$homing/smear.scale.z = smearLength * 0.4
		posLastFrame = global_position
	else:
		$homing/smear.visible = false
	
	## Influence direction of homing
	var lerpSpeed := 0.06
	if get_input_axis():
		lerpSpeed = 0.5
	
	%homingTarget.position.x = lerp(%homingTarget.position.x, 5 * Input.get_axis("left", "right"), lerpSpeed)
	%homingTarget.position.z = lerp(%homingTarget.position.z, 5 * Input.get_axis("forward", "back"), lerpSpeed)
	$homing/area.rotation_degrees.z = lerp($homing/area.rotation_degrees.z, 28 * Input.get_axis("left", "right"), lerpSpeed)
	$homing/area.rotation_degrees.x = lerp($homing/area.rotation_degrees.x, 28 * Input.get_axis("back", "forward"), lerpSpeed)
	#$homing/area.rotation_degrees.x = 25 * Input.get_axis("back", "forward")
	
	## Diving/homing end ##
	
	
	
	## Flop Animation
	var amp = max(angular_velocity.length() * 0.18, linear_velocity.length())
	flopTimer += 1 
	%pivotUpper.rotation_degrees.z = sin(flopTimer * 0.3) *  3*clamp(amp, 1, 10)
	%pivotLower.rotation_degrees.z = sin(flopTimer * 0.3) * -3*clamp(amp, 1, 10)
	%pivotHead.rotation_degrees.z = sin(flopTimer * 0.3) *  6*clamp(amp, 1, 10)
	%pivotTail.rotation_degrees.z = sin(flopTimer * 0.3) *  -6*clamp(amp, 1, 10)  
	
	
	## Particle Effects
	if amp >= 3:
		$BubbleRing.emitting = true
	else:
		$BubbleRing.emitting = false
	

	
	
	
	
	## Restart
	if global_position.y < -15:
		ScoreManager.end_combo() #reset combo
		#get_tree().reload_current_scene()
		position = checkpoint_pos
		if surfMode:
			deactivateSurfMode()
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		
	
	
	################
	##   CAMERA   ##
	################
	#fov
	%cam.fov = lerp(%cam.fov, 80.0, 0.1)   
	if %cam.fov > 79.99:
		%cam.fov = 80
	
	#camera controller areas
	if $detectCamSwitch.has_overlapping_areas():
		var area = $detectCamSwitch.get_overlapping_areas()[0]
		targetCamAngle = area.newCameraAngle
		targetCamOffset = area.newCameraOffset
		targetCamDist = area.newCameraDistance
		if area.target != null:
			%camera_target.global_position = area.target.global_position
			targetCamOffset = %camera_target.position
			targetCamOffset += area.newCameraOffset
		camSpeed = area.rate
		cameraOverride = true #so you cant move the cam manually in switch areas
	elif cameraOverride == false:
		targetCamAngle = Vector3(-30,0,0) #default camera settings
		targetCamOffset  = Vector3(0,0.58,0)
		targetCamDist = 5.2
		camSpeed = 0.2
		#lower camera when close to a ceiling
		if %ceilDetect.is_colliding():                                   #clamp min to 1
			var dist = max(%ceilDetect.get_collision_point().y - global_position.y, 1)
			targetCamOffset.y = 0.58 - (4 - dist)
		
	 
	
	#Manual camera control
	if Input.is_action_pressed("camera") and !cameraOverride:
		if get_input_axis():
			cameraOverride = true
		if get_input_axis().x != 0:
			var LR = Input.get_axis("right", "left")
			targetCamAngle.y = 30 * LR
			targetCamOffset = Vector3(-2.5*LR, 0.58, 0.6)
		elif Input.is_action_pressed("forward"):
			targetCamAngle.x += 40
			targetCamOffset = Vector3(0, 2.3, -1.5)
		elif Input.is_action_pressed("back"):
			targetCamAngle.x -= 15
			targetCamOffset = Vector3(0,-0.7,3.5)
	
	if !Input.is_action_pressed("camera"): #reset camera when you let go of C
		cameraOverride = false
	
	
	
	##Slowly pan the camera towards the desired location
	%camFocus.rotation_degrees = %camFocus.rotation_degrees.lerp(targetCamAngle, camSpeed) #angle of focus
	%camFocus.position = %camFocus.position.lerp(targetCamOffset, camSpeed) #Position of focus
	%cam.position.z = lerp(%cam.position.z, targetCamDist, camSpeed) #Distance from focus
	#%camFocus.global_position = camLockOnTarget.global_position
	var targetTilt = 0.0
	if homingLookDown and !$detectCamSwitch.has_overlapping_areas():
		targetTilt = -24.0
	%cam.rotation_degrees.x = lerp(%cam.rotation_degrees.x, targetTilt, 0.1)
	
	
	
	## Audio (flopping sfx) ##
	#the cooldown gets shorter the faster you are
	sfxCoolDown += clamp(amp, 0, 8) #caps at 8
	
	if get_contact_count() > 0 and sfxCoolDown > 30 and amp >= 0.4 and !surfMode:
		sfxCoolDown = 0
		
		if amp >= 14:
			$Hard_Impact.pitch_scale = 1
			$Hard_Impact.play()
			#print("play hard, pitch: ", $Hard_Impact.pitch_scale, " speed: ", amp )
			$JumpPuff.restart() #harsh particles
			$JumpPuff.emitting = true
		elif amp >= 8:                   #from 0.8 to 1.17 at amp 14
			$Medium_Impact.pitch_scale = 0.35 + amp / 15
			$Medium_Impact.play()
			#print("play meduim, pitch: ", $Medium_Impact.pitch_scale, " speed: ", amp )
		else:                         #from 0.7 to 1.3 at amp 8
			$Soft_Impact.pitch_scale = 0.7 + amp / 15
			$Soft_Impact.play()
			#print("play soft, pitch: ", $Soft_Impact.pitch_scale, " speed: ", amp )
	
	
	  
	  
	###################
	##  STYLE METER  ##
	################### 
	
	
	## Hangtime
	if is_in_air() and !%nearFloor.is_colliding(): 
		ScoreManager.give_points(clamp(height, 1, 10), 0, false, "HANGTIME")
	
	## SPEEN
	if angular_velocity.length() > 100:
		ScoreManager.give_points(angular_velocity.length()*0.05,0,false, "SPEEN")
	
	
	
	## Tipspin
	isTipSpinning = false
	wallGrind = move_toward(wallGrind, 0, 1)
	if get_side_count() == 1 and ($trickRC/tail.is_colliding() or $trickRC/head.is_colliding()):
		tipLandAntiCheese += 1
	else:
		tipLandAntiCheese = 0
	if tipLandAntiCheese > 3: 
		if linear_velocity.length() > 0.1 and angular_velocity.length() > 10 and !surfMode:
			isTipSpinning = true
			ScoreManager.give_points(500/(linear_velocity.length()*2), 0, true, "TIPSPIN")
			if height > 2:
				ScoreManager.give_points(angular_velocity.length()*4, 0, true, "WALL TIPSPIN")
				wallGrind += 2 #+2 to counteract the -1 so its actually +1
			if wallGrind == 50: #wall tipspin for 50 frames in a row
				ScoreManager.give_points(0, 15, true, "WALLGRIND")
				ScoreManager.play_trick_sfx("legendary")
				wallGrind = -200 #extra cooldown
			#ScoreManager.give_points(1, 0, true, "TIPSPIN", "", false)
			#print("spd: ", linear_velocity.length(), "  score: ", 500/(linear_velocity.length()*2) )
			if ScoreManager.mult == 0: #in case you do a tipspin without a combo first
				ScoreManager.give_points(0, 1, true)
		
		
		## Tip landing
		if !tiplanding and !isHeld and !surfMode:
			if linear_velocity.length() < 0.05 and angular_velocity.length() < 0.05:
				tiplanding = true
				ScoreManager.give_points(999999, 200, true, "TIPLANDING HOLY SHIT")
				ScoreManager.change_rank(8, 1)
				ScoreManager.comboTimer += 500
				ScoreManager.play_trick_sfx("legendary")
				MusicManager.play_track(1)
				MusicManager.play_track(2)
				MusicManager.play_track(3)
				MusicManager.play_track(4)
	
	if is_in_air():
		tiplanding = false #reset tiplanding is the air so you can do it again
	
	#Spark Particles
	$tipSpinSparks.emitting = isTipSpinning
	%ballSpark.emitting = isTipSpinning
	var sparkSpd = clamp(angular_velocity.length() * 0.06 +0.3, 0.8, 4)
	$tipSpinSparks.speed_scale = sparkSpd
	var sparkRate = clamp(angular_velocity.length()*0.03, 0.3, 1)
	$tipSpinSparks.amount_ratio = sparkRate
	var sfxRate = int(clamp(30 - angular_velocity.length()*0.5, 5, 25))
	
	%particleFloor.position.y = -height -1
	
	%speedLines1.rotation_degrees.y += angular_velocity.y*0.4
	%speedLines2.rotation_degrees.y += angular_velocity.y*0.5
	%speedLines3.rotation_degrees.y += angular_velocity.y*0.6
	%speedLines1.visible = true
	%speedLines2.visible = true
	%speedLines3.visible = false
	var transp = abs(angular_velocity.y)*0.02
	if !isTipSpinning: #make it harder to see the speed lines when not tipspinning
		transp -= 0.3
		%speedLines1.visible = false #make the speed lines wider when in the air,
		%speedLines3.visible = true #but thinner and taller when tipspinning
	%speedLines.visible = !surfMode
	transp = 1 - clamp(transp, 0 ,1)
	%speedLines1.transparency = transp
	%speedLines2.transparency = transp
	%speedLines3.transparency = transp
	
	if GameManager.gameTimer % sfxRate == 0 and isTipSpinning:
		$grindingSparks.play()
	
	var trackPos
	var trackAng
	
	if $trickRC/head.is_colliding():
		$tipSpinSparks.position.x = -0.7
		$tipSpinSparks.rotation_degrees.y = -180
		trackPos = $trickRC/head.get_collision_point()
		trackAng = $trickRC/head.get_collision_normal()
	else:
		$tipSpinSparks.position.x = 0.7
		$tipSpinSparks.rotation_degrees.y = 0
		trackPos = $trickRC/tail.get_collision_point()
		trackAng = $trickRC/tail.get_collision_normal()
	
	
	## Tire tracks
	if isTipSpinning: #flopTimer % 5 == 0 and
		var newDecal = $Decal.duplicate()
		add_child(newDecal)
		newDecal.theOriginal = false
		newDecal.global_position = trackPos
		#set the angle with complicated math
		newDecal.global_transform.basis.y = trackAng
		newDecal.global_transform.basis.x = -newDecal.global_transform.basis.z.cross(trackAng)
		newDecal.global_transform.basis = newDecal.global_transform.basis.orthonormalized()
		#size is 0.2 at spd 16 | 0.5 at spd 50
		var size = 0.2 + (angular_velocity.length() - 16) * 0.008
		size = clamp(size, 0.2 , 0.5)
		newDecal.size.x = size
		newDecal.size.z = size
		newDecal.visible = true
		
	
	
	##TODO: and skate sounds for skateboard
	##TODO: UI follows camera change,
	##TODO: combo list on screen whenever u do a surf trick,
	
	var surfSparkSpd
	var surfSparkRate
	######################
	##   Sign Surfing   ##
	######################
	surfState = "Not surfing"
	var floor_normal = %canSurf.get_collision_normal().normalized() #deaulf value to avoid crash
	$sign_scraping.volume_linear = 0
	%surfSparks.emitting = surfMode and %surfRC3.is_colliding()
	
	if surfMode:
		#Particles
		surfSparkSpd = clamp(( linear_velocity.length()-5)*0.1 +1, 1, 5) #1 at 5, 5 at 45
		%surfSparks.speed_scale = surfSparkSpd
		surfSparkRate = clamp( (linear_velocity.length()-5)*0.03, 0, 1) #0 at 5, 1 at 38
		%surfSparks.amount_ratio = surfSparkRate
		
		# < 5 no sparks
		
		
		
		#audio
		$sign_scraping.volume_linear = clamp(linear_velocity.length()*0.05 -0.1, 0, 0.5)
		$sign_scraping.pitch_scale = clamp(0.5 + linear_velocity.length()/25, 0.5, 2)
		#print($sign_scraping.volume_linear)
		
		#leaning
		%fishPivot.visible = true
		%fishPivot.rotation = %area.rotation #use the rotation of homing hitbox to lean
		var vec3 : Vector3 = %fishPivot.rotation
		%fishPivot.rotation = vec3.rotated(Vector3(0,1,0), -$surfPivot.rotation.y)
		%fishPivot.rotation *= -0.5
		
		#so he doesnt looks flat when facing directly up or down
		if abs($surfPivot.rotation_degrees.y) > 170 or abs($surfPivot.rotation_degrees.y) < 10:
			%fishPivot.rotation_degrees.y = -30 
		
		
		if %canSurf.is_colliding(): #the one thats always pointing globally down
			isHalfPiping = false
			if %surfRC2.is_colliding(): #the one thats pointing under the surf board
				surfState = "Normal surfing"
				floor_normal = getSurfNormal()
			else:
				surfState = "landing after a tumble"
				floor_normal = %canSurf.get_collision_normal().normalized() 
		else:
			if %surfRC1.is_colliding(): #pointing under the board but at the front
				surfState = "Slope surfing"
				isHalfPiping = true
				floor_normal = getSurfNormal()
			else:
				surfState = "Jumping"
				$sign_scraping.volume_linear = 0
				updateInputHistory()
		
		##Surfing or non-halfpipe jump
		if surfState != "Jumping":
			var vel_dir = linear_velocity.normalized()
			var forward = vel_dir.slide(floor_normal).normalized()
			var right = forward.cross(floor_normal).normalized()
			var newBasis = Basis(right, floor_normal, -forward).orthonormalized()
			$surfPivot.global_transform.basis = newBasis
			ScoreManager.reset_airspin()
			surfRotationType = ""
			inputHistory = ["","",""]
			
		else: ##Rotating in the air
			
			if $surfPivot.global_transform.basis.y.y < 0.45 and isHalfPiping and !%halfPipeCheck.is_colliding():
				if surfState == "Jumping" and linear_velocity.y > 5:
					surfRotationType = "clockwise"
					ScoreManager.give_points(5000, 0, true, "HALFPIPE")
					ScoreManager.play_trick_sfx("rare")
					isHalfPiping = false
					print("AUTO HALF PIPE SPIN")
			
			
			var curBasis = $surfPivot.global_transform.basis
			var spinSpeed = angular_velocity.length() * 0.06 * _delta * spinBoostBonus
			spinBoostBonus = max(spinBoostBonus-0.1, 1)
			
			
			if height > 10 and linear_velocity.y < 0 and surfRotationType == "":
				surfRotationType = "tumble"
			if surfRotationType == "tumble":
				print("AIR TUMBLE")                                 #this adds a bit of non-rng randomness 
																	#to the tumble spin direction
				curBasis = curBasis.rotated(curBasis.y, spinSpeed*0.2*sign(angular_velocity.y))
				curBasis = curBasis.rotated(curBasis.x, spinSpeed*0.2*sign(angular_velocity.x))
				curBasis = curBasis.rotated(curBasis.z, spinSpeed*0.2*sign(angular_velocity.z))
				$surfPivot.global_transform.basis = curBasis 
			
			if surfRotationType == "clockwise" or surfRotationType == "counterClockwise":
				if surfRotationType == "clockwise":
					spinSpeed *= -1
				$surfPivot.global_transform.basis = curBasis.rotated(curBasis.y, spinSpeed)
				ScoreManager.airSpinAmount += abs(rad_to_deg(spinSpeed))
			if surfRotationType == "frontFlip" or surfRotationType == "backFlip":
				if surfRotationType == "backFlip":
					spinSpeed *= -1
				$surfPivot.global_transform.basis = curBasis.rotated(curBasis.x, spinSpeed)
				ScoreManager.airSpinAmount += abs(rad_to_deg(spinSpeed))
			if surfRotationType == "leftFlip" or surfRotationType == "rightFlip":
				if surfRotationType == "rightFlip":
					spinSpeed *= -1
				$surfPivot.global_transform.basis = curBasis.rotated(curBasis.z, spinSpeed)
				ScoreManager.airSpinAmount += abs(rad_to_deg(spinSpeed))
				
				
		
		
	
	
	if linear_velocity.length() < 0.1 and !tiplanding and !isHeld:
		ScoreManager.idle = true
	else:
		ScoreManager.idle = false
	
	
	
	## Fish button
	if surfMode == false:
		%pivotUpper.visible = true
		%pivotLower.visible = true
	$posing.visible = false
	$flash.visible = false
	%dead_fish.modulate.a -= 0.05
	%dead_fish.scale -= Vector2(0.01, 0.01)
	fishCooldown += 1
	if Input.is_action_just_pressed("FIsh") and !isHeld:
		$FIsh.play()
		$recordingManager.fishPressed = true
		if height > 6 and abs(linear_velocity.y) < 6 and fishCooldown > 60:
			GameManager.hitstop(20)
			ScoreManager.give_points(height*500, 5, true, "POSE FOR THE CAMERA")
			ScoreManager.comboTimer += 80 #give you extra time
			ScoreManager.update_freshness(self)
			$taunt.play()
			$pivotUpper.visible = false
			$pivotLower.visible = false
			%fishPivot.visible = false
			$posing.visible = true
			$flash.visible = true
			$tauntAnimation.play("taunt")
		else:
			ScoreManager.give_points(100, 0, false, "FISH!")
			%dead_fish.visible = true
			%dead_fish.modulate.a = 1
			%dead_fish.scale = Vector2(1.2, 1.2)
		fishCooldown = 0
	
	
	## AIR SPIN
	var deg_vel = angular_velocity.length() #get rotation speed
	deg_vel = rad_to_deg(deg_vel) / 60 #transform radians per second into degrees per frame 
	
	if surfMode == false:
		ScoreManager.airSpinAmount += deg_vel
	
	#reset when touching the floor
	if get_contact_count() > 0 and %nearFloor.is_colliding(): 
		ScoreManager.reset_airspin()
		
	
	
	##speed lines 
	var target = 0.5 - (linear_velocity.length()-25.0)*0.0125 #0.7 at <30 | 0.43 at 30 | 0.0 at 65
	target = clamp(target, 0, 7)
	if target > 0.5: #if slowly then 30, well slowly make it too big to be visible
		target = 0.7 #at 0.7 its just enough to not be visible
	var current = %speedLinesShader.material.get_shader_parameter("clipPosition")
	 
	var lineLen    #slowly move from the current length to the goal one
	if current > target:  #when ACCELERATING, make the speed line reach the goal much faster
		lineLen = move_toward(current, target, 0.08)
	else:                #when slowing down, make the speed lines slowly go away
		lineLen = move_toward(current, target, 0.01)
	%speedLinesShader.material.set_shader_parameter("clipPosition", lineLen)
	#print("cur: ", current, " target: ", target)
	
	## Speed wind SFX
	#DECIBEL TO LINEAR CHEAT SHEET
	#-20 : 0.1     -6 : 0.5   0 : 1.0   6 : 2.0   12 : 4.0    20 : 10.0
	var speed = linear_velocity.length()
	var windVolume
	if speed < 15:
		windVolume = 0
	else:
		windVolume = (speed-15) * 0.04  #0 at 15   2 at 50
		windVolume = clamp(windVolume*1.5, 0, 4) #caps to 4 at 80
	#adds fade in and fade out
	$speedWind.volume_linear = move_toward($speedWind.volume_linear, windVolume, 0.2)
	
	#extra pitch when you go really fast
	if speed <= 40:
		$speedWind.pitch_scale = 1
	else:                             #1 at 50     3 at 200
		$speedWind.pitch_scale =clamp( (speed-50)*0.013 + 1, 1, 3)
	
	
	
	#DEBUG_INFO
	%debugLabel2.text = str("speed: ", snapped(linear_velocity.length(), 0.01),"\n",
	"spark speed: ", surfSparkSpd, "\n",
	"spark rate: ", surfSparkRate, "\n",
	"rotation:", angular_velocity, "
	spin: ", snapped(angular_velocity.length(), 0.01), "
	surf jump: ", surfJumpHolding, "
	surf state: ", surfState, "
	Rotation Type: ", surfRotationType, "
	last input ago: ", timeSinceLastInput, "
	input hitory: ", inputHistory, "
	isHalfPiping: ", isHalfPiping, "
	floor normal: ", floor_normal, "
	y.y basis: ", $surfPivot.global_transform.basis.y.y, "
	spinBoostBonus: ", spinBoostBonus, "\n")
	
	
	%debugLabel.text = str(
	"fov: ", %cam.fov, "\n",
	"height: ", snapped(height, 0.01), "\n",
	"linear velocity: ", snapped(linear_velocity, Vector3(0.01,0.01,0.01)), "\n",
	"speed: ",  snapped(linear_velocity.length(), 0.01), " (",windVolume,")",  "\n",
	"angular velocity: ", snapped(angular_velocity, Vector3(0.01,0.01,0.01)), "\n",
	"spin speed: ", snapped(angular_velocity.length(), 0.01), "\n",
	"diving: ", diving, "\n",
	"target: ", get_collider_name($homing/raycast), "\n",
	"camera rc: ", get_collider_name(%ceilDetect), "\n",
	"timeSinceNoTargets: ", timeSinceNoTargets, "\n",
	"homingLookDown: ", homingLookDown, "\n",
	"gravity scale: ", gravity_scale, "\n", 
	)
	



func activateSurfMode(sprite : String, signObj : Node):
	surfMode = true
	surfSignRef = signObj
	if diving:
		linear_velocity.y = 0
		linear_velocity *= 0.5
		apply_impulse(JUMP_STRENGTH)
	surfJumpHolding = 5
	%surfSign.texture = load(sprite)
	%surfSign.rotation_degrees.y = 0
	if sprite.get_file().begins_with("long_"):
		%surfSign.rotation_degrees.y = 90
	%surfSignUnder.visible = sprite.get_file().contains("skateBoard") #skateboard underside
	%surfSign.double_sided = !%surfSignUnder.visible
	$surfPivot.visible = true
	%pivotUpper.visible = false
	%pivotLower.visible = false
	$shadowMesh.visible = false
	$collision.set_deferred("disabled", true)
	$collisionSphere.set_deferred("disabled", false)
	ScoreManager.comboTimer += 80 #give you extra time
	ScoreManager.reset_airspin()
	ScoreManager.airSpinHighestRank = 0


func deactivateSurfMode():
	surfMode = false
	inputHistory = ["","",""]
	surfSignRef.global_position = global_position
	surfSignRef.reset_physics_interpolation()
	surfSignRef.throwAway()
	$surfPivot.visible = false
	$shadowMesh.visible = true
	$collision.set_deferred("disabled", false)
	$collisionSphere.set_deferred("disabled", true)
	hasSurfedBefore = true
	ScoreManager.reset_airspin()
	#ScoreManager.airSpinHighestRank = 0
	

func getSurfNormal():
	var raycasts : Array = []
	if %surfRC1.is_colliding():
		raycasts.append(%surfRC1.get_collision_normal())
	if %surfRC2.is_colliding():
		raycasts.append(%surfRC2.get_collision_normal())
	if %surfRC3.is_colliding():
		raycasts.append(%surfRC3.get_collision_normal())
	var finalVector : Vector3 = Vector3.ZERO
	for ray in raycasts:
		finalVector += ray
	
	return finalVector.normalized()


func updateInputHistory():
	timeSinceLastInput += 1
	if timeSinceLastInput == 1: #so you can just spam keys randomly super fast
		return
	if Input.is_action_just_pressed("forward"):
		inputHistory.append("up")
		print(timeSinceLastInput)
	elif Input.is_action_just_pressed("back"):
		inputHistory.append("down")
		print(timeSinceLastInput)
	elif Input.is_action_just_pressed("left"):
		inputHistory.append("left")
		print(timeSinceLastInput)
	elif Input.is_action_just_pressed("right"):
		inputHistory.append("right")
		print(timeSinceLastInput)
	
	if timeSinceLastInput == 30:
		inputHistory = ["","",""]
	
	
	while inputHistory.size() >= 4:
		inputHistory.remove_at(0)
		timeSinceLastInput = 0
	
	
	var prevRotation = surfRotationType
	var newTrick = false           #Yes I couldnt think of a better way to code this, shut up
	if inputHistory == ["up","left","down"] or inputHistory == ["left","down","right"] or inputHistory == ["down","right","up"] or inputHistory == ["right","up","left"]:
		if surfRotationType != "rightFlip": #dont allow you to perform the same spin AGAIN but in the other direction
			surfRotationType = "leftFlip"
			newTrick = true
	if inputHistory == ["up","right","down"] or inputHistory == ["right","down","left"] or inputHistory == ["down","left","up"] or inputHistory == ["left","up","right"]:
		if surfRotationType != "leftFlip":
			surfRotationType = "rightFlip"
			newTrick = true
	if inputHistory == ["down", "up", "down"]:
		if surfRotationType != "backFlip":
			surfRotationType = "frontFlip"
			newTrick = true
	if inputHistory == ["up", "down", "up"]:
		if surfRotationType != "frontFlip":
			surfRotationType = "backFlip"
			newTrick = true
	if inputHistory == ["right", "left", "right"]:
		if surfRotationType != "counterClockwise":
			surfRotationType = "clockwise"
			newTrick = true
	if inputHistory == ["left", "right", "left"]:
		if surfRotationType != "clockwise":
			surfRotationType = "counterClockwise"
			newTrick = true
	if newTrick:
		inputHistory = ["","",""]
		if angular_velocity.length() < 80:
			angular_velocity *= 80/angular_velocity.length()
		
		
		
		if surfRotationType == prevRotation: 
			ScoreManager.give_points(800, 0, true, "INPUT COMBO")
			if angular_velocity.length() < 250:
				angular_velocity *= 1.10 #doing the same rotation twice in a row
			spinBoostBonus = 2.0
			$THPS_low.play()
		else:
			ScoreManager.give_points(1000, 0, true, "INPUT COMBO")
			if angular_velocity.length() < 250:
				angular_velocity *= 1.20 #doing a different rotation
			spinBoostBonus = 2.5
			$THPS_high.play()
			
		



## This functions takes in a vector, and rotates it so that forward points
## towards where the camera is looking
func rotate_by_cam(vector : Vector3):
	return vector.rotated(Vector3(0,1,0), %cam.global_rotation.y)

##Helps with clarity when debugging
func get_collider_name(c):
	if !c.is_colliding():
		return ""
	else:
		return str(c.get_collider().name, " (", c.get_collider().get_parent().name, ")")
	

func detailed_name(object):
	return str(object.name, " (", object.get_parent().name, ")")


## Returns a Vector2D based on which arrow keys are pressed
## X:  Left: -1  Right: 1       Y:  Down: -1  Up: 1
## Result is 0 if both or neither are pressed.
## You can also use it as a boolean: no input == false, any input == true
func get_input_axis():
	var x = Input.get_axis("left", "right")
	var y = Input.get_axis("back", "forward")
	return Vector2(x,y)

##Temporarily change the FOV of the camera for a zoom-in impact effect
func set_fov(newFov:float):
	%cam.fov = newFov

func get_side_count():
	var count = 0
	for raycast in $trickRC.get_children():
		if raycast.is_colliding():
			count += 1
	return count

## Returns true when there is 0 physical contacts
func is_in_air(): 
	if get_contact_count() == 0:
		return true
	else:
		return false
		

func set_skin(): #doesnt work yet
	var skin = preload("res://Skins/lemmedoitfoyew.png")
	$pivotUpper/upperBody.texture = skin
	$pivotUpper/pivotHead/head.texture = skin
	$pivotLower/lowerBody.texture = skin
	$pivotLower/pivotTail/tail.texture = skin
	

func force_position(newPos : Vector3):
	global_position = newPos
	if not surfMode: #when surfing, this causes some weird divide by 0 glitch 
		linear_velocity = Vector3(0,0,0) 
		angular_velocity = Vector3(0,0,0)

func get_closest_target():
	var crabs = $homing/area.get_overlapping_areas()
	var detectedCrabs = []
	
	## Weed out all of the crabs behind a walls
	for crab in crabs:
		var direction = global_position.direction_to(crab.global_position)
		$homing/raycast.target_position = direction*5
		$homing/raycast.force_raycast_update()
		if $homing/raycast.get_collider() == crab:
			detectedCrabs.append(crab)
	
	if detectedCrabs.is_empty(): ## If every crab is behind a wall
		return null
	if detectedCrabs.size() == 1: ## Skip the sorting algo if theres only 1 left
		return detectedCrabs[0]
	
	## Find which remaining target is the closest
	var closest = detectedCrabs[0]
	for crab in detectedCrabs:
		#if the crab is nearer than the previous closest
		if %homingTarget.global_position.distance_to(crab.global_position) <= %homingTarget.global_position.distance_to(closest.global_position):
			if crab.priority >= closest.priority: #if the crab has >= priority than previous closest
				closest = crab
	
	#so debbing rc looks at the correct crab
	var rcDirection = global_position.direction_to(closest.global_position)
	$homing/raycast.target_position = rcDirection*5
	
	return closest
