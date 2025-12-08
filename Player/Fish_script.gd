@icon("res://icons/fish.png")
class_name player 
extends RigidBody3D

#jump check
@export var canJump: bool = true
@export var noScoreUI : bool = false
@export var canMove : bool = true #so you cant move at the start of the tutorial
@export var legacyCamera : bool = true

var checkpoint_pos: Vector3

#camera
var targetCamAngle: Vector3
var defaultCameraAngle : Vector3 = Vector3(-30,0,0)
var targetCamOffset : Vector3
var defaultCameraOffset : Vector3 = Vector3(0,0.58,0)
var targetCamDist: float
var defaultCameraDistance: float = 6.0
var camSpeed: float = 0.2
var cameraOverride: bool = false
var homingLookDown : bool = false ##used to make the cam tilt down when chaining homing dives
var VcameraSetting : int = 1 ##0: looking up/forward 1: regular 2: homing looking down 3: topdown
var autoCamTurning : bool = true


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
var diveReboundTimer : int = 0
var heightWhenDiveBegun : float = 0
var justDiveRebounded : bool = false
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
var skateboardSurf : bool = false #if the "sign" used for surfing is a skateboard
var fallSpeeds : Array = [0, 0]
var isRailGrinding : bool = false
var currentRailObj : railGrind = null
var targetingRail : bool = false #if the current homing target is a railgrind
var railCooldown : int = 0 #Stops the game from fucking crashing and somehow also crashing hams's audio

#Bubble boost variables
var bubbleMode : bool = false

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

#OTHER
var noclip := false
var jumpPreview : Vector2
var deactivateDive : int = 0


var trueSpeed := Vector3(0,0,0) #Keeps track of how fast you're moving in global space

func _ready() -> void:
	checkpoint_pos = position
	posLastFrame = global_position
	ScoreManager.fish = self
	%speedLinesShader.material.set_shader_parameter("clipPosition", 0.7)
	$Decal.visible = false
	$surfPivot.visible = false
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if noScoreUI:
		ScoreManager.hide()
	#set debug switch effects
	MenuManager._on_noclip_toggled() 
	%debugLabel.visible = MenuManager.fish_debug_on()
	%debugLabel2.visible = MenuManager.surf_debug_on()
	if legacyCamera == true:
		$UI/camIcon.visible = false


func _physics_process(_delta: float) -> void:
	var accel = ACCEL
	if surfMode:
		accel = SURFACCEL
	
	
	
	## Movement
	if canMove:
		if Input.is_action_just_pressed("forward"):
			if !surfMode or !%SRCACforward.is_colliding(): #fixes the ability to infinitely climb walls while surfing. yes this is stupid.
				apply_torque_impulse(rotate_by_cam(torque_impulse))
				apply_impulse(rotate_by_cam(Vector3(0, 0, -accel)))
		
		if Input.is_action_just_pressed("back"):
			if !surfMode or !%SRCACbackwards.is_colliding():
				apply_torque_impulse(rotate_by_cam(torque_impulse * -1))
				apply_impulse(rotate_by_cam(Vector3(0, 0, accel)))
		
		if Input.is_action_just_pressed("right"):
			if !surfMode or !%SRCACright.is_colliding():
				apply_torque_impulse(rotate_by_cam(torque_side * -1))
				apply_impulse(rotate_by_cam(Vector3(accel, 0, 0)))
		 
		if Input.is_action_just_pressed("left"):
			if !surfMode or !%SRCACleft.is_colliding():
				apply_torque_impulse(rotate_by_cam(torque_side))
				apply_impulse(rotate_by_cam(Vector3(-accel, 0, 0)))
	
	#print(get_input_axis().angle())
	
	
	$longJumpPreview.global_position = global_position
	
	$UI/jump.text = ""
	var xVel = Vector2(linear_velocity.x, linear_velocity.z) 
	$UI/jump.text += str("global hspeed: ", snapped(xVel.length(), 0.01), " ", snapped(xVel,Vector2(0.01,0.01)))
	#$longJumpPreview/RayCast3D.target_position = Vector3(xVel.x, 0, xVel.y)
	$longJumpPreview/global.rotation.y = atan2(xVel.x, xVel.y)
	$longJumpPreview/global.scale.z = xVel.length()
	
	xVel = xVel.length()
	var newVel = Vector3(0,0,-xVel)
	newVel = rotate_by_cam(newVel)
	$UI/jump.text += str("\nin cam direction: ", snapped(newVel.length(), 0.01), " ", snapped(newVel,Vector3(0.01,0.01,0.01)))
	$longJumpPreview/camera.rotation.y = atan2(newVel.x, newVel.z)
	$longJumpPreview/camera.scale.z = newVel.length()
	
	newVel = Vector2(newVel.x, newVel.z)
	newVel = newVel.rotated(get_input_axis().angle()+PI/2)
	$longJumpPreview/control.rotation.y = atan2(newVel.x, newVel.y)
	$longJumpPreview/control.scale.z = newVel.length()
	if !get_input_axis():
		$longJumpPreview/control.scale.z = 0
	
	newVel = Vector3(newVel.x, linear_velocity.y, newVel.y)
	#vector.rotated(Vector3(0,1,0), %cam.global_rotation.y)
	
	
	diveReboundTimer -= 1
	if diveReboundTimer == 0:
		heightWhenDiveBegun = 0
	
	#Walljump hitbox
	var newRadius = 0.55 + (trueSpeed.length()*0.01) + (angular_velocity.length()*0.001)
	
	
	%floorDetection.shape.radius = move_toward(%floorDetection.shape.radius, newRadius, 0.01)
	#print("speed: ", snapped(linear_velocity.length()*0.01, 0.01), " ang: ", snapped(angular_velocity.length()*0.001, 0.01)," target: ", snapped(newRadius, 0.01), " radius: ", snapped(%floorDetection.shape.radius, 0.01) )
	
		###############
		##  Jumping  ##
	timeSinceJump += 1 #so you cant jump twice in a row when spamming
	if Input.is_action_just_pressed("jump") and (canJump or noclip) and !isRailGrinding and !diving:
		if !%nearFloor.is_colliding() and surfMode and !noclip:
			pass #Disable walljumps in surf mode
		elif (timeSinceJump > 20 and %floorDetection.is_colliding()) or noclip:
			timeSinceJump = 0
			#audio
			if surfMode:
				$skateJumping.play()
			else:
				$Jumps.play()
				$Soft_Impact.play()
			
			#jump Particle
			$JumpPuff.restart()
			$JumpPuff.emitting = true
			
			
			print("JUST JUMPED: rebound timer: ", diveReboundTimer)
			
			#apply vertical speed
			apply_impulse(JUMP_STRENGTH)
			if !get_input_axis():
				apply_torque_impulse(rotate_by_cam(torque_impulse)) #flop forward
			
			#mid Air extra control
			var boost = (ACCEL * 3) + clamp(angular_velocity.length()*0.15, 0, 20)
			
			if diveReboundTimer > 0 and get_input_axis():
				print("DIVE LONG JUMP, boost before: ", boost, " and after: ", boost+dive_rebound_strength())
				boost += dive_rebound_strength()
				justDiveRebounded = true
			
			
			#print("long jump boost: 4.5 + ", clamp(angular_velocity.length()*0.15, 0, 20), " = ", boost)
			
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
				apply_impulse( Vector3(0, boost*0.2, 0) )
				
				#xVel = Vector2(linear_velocity.x, linear_velocity.z) 
				#xVel = xVel.length()
				#newVel = Vector3(0,0,-xVel)
				#newVel = rotate_by_cam(newVel)
				#newVel = Vector2(newVel.x, newVel.z)
				#newVel = newVel.rotated(get_input_axis().angle()+PI/2)
				#newVel = Vector3(newVel.x, linear_velocity.y, newVel.y)
				#linear_velocity = newVel
				
			
			## Style Meter and jump related tricks
			superJumpTimer = 3 #check your speed 3 frames after jumping
			
			if is_in_air() and %nearFloor.is_colliding():
				ScoreManager.give_points(1000,0, true, "POGO JUMP", "uncommon")
				angular_velocity *= 1.1
				#play_trick_sfx("uncommon")
			
			if !%nearFloor.is_colliding():
				ScoreManager.give_points(800,1, true, "WALL JUMP", "uncommon")
				ScoreManager.reset_airspin()
				ScoreManager.tutorialChecklist["walljump"] += 1
				print("Airspin reset by walljump")
				#play_trick_sfx("uncommon")
			
			
			if !get_input_axis(): #High Jump
				var xtraYspd = clamp(angular_velocity.length()*0.35, 0, 35)
				
				if diveReboundTimer > 0:
					print("DIVE HIGH JUMP, boost before: ", xtraYspd, " and after: ",xtraYspd+dive_rebound_strength())
					xtraYspd += dive_rebound_strength()
					justDiveRebounded = true
				
				
				
				apply_impulse(rotate_by_cam(Vector3(0, xtraYspd, 0)))
				
				#print("high jump! spd: ", linear_velocity.length(), " xtra: ", xtraYspd )
				
				if linear_velocity.length() > 12: #Points
					ScoreManager.give_points(800, 0, true, "HIGH JUMP", "uncommon")
					ScoreManager.tutorialChecklist["highjump"] += 1
			else:
				var hspeed = linear_velocity #get your speed
				hspeed.y = 0  #remove your vertical speed from the equation
				hspeed = hspeed.length() #get your true horziontal speed 
				#print("LONG JUMP, speed: ", hspeed)
				if linear_velocity.length() > 12:
					ScoreManager.give_points(600, 0, true, "LONG JUMP", "uncommon")
					ScoreManager.tutorialChecklist["longjump"] += 1
			
			
	
	## Tutorial jump preview / jump meter:
	if $UI/jumpPreview.visible:
		jumpPreview.y = JUMP_STRENGTH.y
		jumpPreview.x = ACCEL
		if get_input_axis():
			var Ljump = (ACCEL * 3) + angular_velocity.length()*0.15
			jumpPreview.x += Ljump
			jumpPreview.y += Ljump*0.2
			if diveReboundTimer > 0 or diving:
				jumpPreview.x += dive_rebound_strength()
		else:
			jumpPreview.y += angular_velocity.length()*0.35
			if diveReboundTimer > 0 or diving:
				jumpPreview.y += dive_rebound_strength()
		$UI/jumpPreview/ColorRect/arrow.position.x = jumpPreview.x*10 + 35
		$UI/jumpPreview/ColorRect/arrow.position.y = jumpPreview.y*-7
		$UI/jumpPreview/ColorRect/Line1.points[1] = $UI/jumpPreview/ColorRect/arrow.position
		$UI/jumpPreview/ColorRect/Line2.points[1] = $UI/jumpPreview/ColorRect/arrow.position
		$UI/jumpPreview/ColorRect/arrow.rotation = Vector2(0,0).angle_to_point($UI/jumpPreview/ColorRect/arrow.position)
		
	
	## Super Jump tricks
	if superJumpTimer >= 0:
		superJumpTimer -= 1
	if superJumpTimer == 0:
		#print("super jump:  v: ", linear_svelocity.y)
		if linear_velocity.y > 25:
			if !justDiveRebounded:
				ScoreManager.give_points(5000, 5, true, "VERTICAL JUMP")
			ScoreManager.give_extra_combo_time(80) #give you extra time
			ScoreManager.play_trick_sfx("legendary")
		if height < 4: #so it doesnt do it on walljumps
			$sparkCrown.jump(linear_velocity.y)
			$sparkCrown.global_position = %heightDetect.get_collision_point() #place the spark crown
			
			#check if your jumping on a perfectly flat floor or else it gives you a stupid error
			if %heightDetect.get_collision_normal().dot(Vector3(0,1,0)) >= 0.99:
				$sparkCrown.global_rotation = Vector3(0,0,0)
			else:
				$sparkCrown.look_at($sparkCrown.global_position+%heightDetect.get_collision_normal())
				$sparkCrown.rotation_degrees.x -= 90
		
		if justDiveRebounded:
			if trueSpeed.length() > 15:
				ScoreManager.give_points(trueSpeed.length()*200, 1, true, "DIVE REBOUND")
				ScoreManager.give_extra_combo_time(80) #give you extra time
				ScoreManager.tutorialChecklist["rebound"] += 1
			
			justDiveRebounded = false
		
		
	
	## Surf Jump
	if Input.is_action_pressed("jump") and !isRailGrinding:
		surfJumpHolding += 1
		if surfJumpHolding >= 20 and surfMode:
			deactivateSurfMode()
			ScoreManager.give_points(0, 3, true, "SURF JUMP")
			apply_impulse(JUMP_STRENGTH*5)
	else:
		surfJumpHolding = 0
	
	%surfJumpMeter.visible = surfMode# and surfJumpHolding != 0
	%surfJumpMeter.value = surfJumpHolding
	if SettingsManager.minimalisticSurfJump:
		%surfJumpMeter.tint_under.a = 0
		%surfJumpMeter.modulate.a = clamp((surfJumpHolding * 0.25) - 1, 0, 1)
	
	## HOMING ATTACKs
	var closest = null
	var coyoteTimeTarget = false
	if (%homingArea.has_overlapping_areas() or timeSinceNoTargets < 16) and !%nearFloor.is_colliding() and !isHeld and deactivateDive == 0:
		#if !coyoteTimeTarget: #dont get closest target in coyote time bcs there isnt one
		closest = get_closest_target()
		
		if closest == null and timeSinceNoTargets < 16:
			closest = closestLastFrame   ##coyote time
			coyoteTimeTarget = true
			#printerr("TARGET COYOTE TIME")
		
		if Input.is_action_pressed("left") and Input.is_action_pressed("right") and Input.is_action_pressed("forward"):
			closest = null #target canceling
			coyoteTimeTarget = false
		
		if closest != null:
			if closestLastFrame != closest: #when the target changes
				closestLastFrame = closest
				
				#regular reticle or railgrind reticle
				targetingRail = closest.get_parent() is railGrind and surfMode == true
				for child in $reticle/rotate.get_children():
					child.self_modulate.a = float(!targetingRail)
					child.get_child(0).visible = targetingRail
				
				if !$reticle.visible: #only play the animation when it first appears
					$reticle/reticleAnimation.play("reticle_appear1")
					$reticle/sfx.play()
					
			
			$reticle/rotate.modulate.a = abs(1-timeSinceNoTargets*0.05) - 0.2
			if timeSinceNoTargets == 0:
				$reticle/rotate.modulate.a = 1
			#print("no target: ", timeSinceNoTargets, " fade: ", $reticle/rotate.modulate.a)
			
			$reticle.position = get_viewport().get_camera_3d().unproject_position(closest.global_transform.origin)
			var center =  MenuManager.get_UI_size()/2
			#If the target is behind the camera, the reticle gets reversed, so unreverse it.
			if get_viewport().get_camera_3d().is_position_behind(closest.global_transform.origin):
				$reticle.position = center - ($reticle.position - center).normalized() * center.length()
			
			var posBefore = $reticle.position
			$reticle.position.x = clamp($reticle.position.x, 50, MenuManager.get_UI_size().x-50)
			$reticle.position.y = clamp($reticle.position.y, 50, MenuManager.get_UI_size().y-50)
			
			if posBefore != $reticle.position: ##When target is off screen
				set_offscreen_reticle(center, posBefore, closest)
			else:
				$reticle/offScreenArrow.visible = false
				$reticle/icon.visible = false
			
			$reticle/rotate.rotation_degrees += 3
			var newScale = sin(flopTimer*0.157) * 0.15 + 1
			$reticle/rotate.scale = Vector2(newScale, newScale)
			$reticle.visible = true
			if $reticle.position.y >= 945 and homing:
				homingLookDown = true
				VcameraSetting = 1
		else: #when closest is null
			$reticle.visible = false
			closestLastFrame = null
	else: #when you can't dive
		$reticle.visible = false
		closestLastFrame = null
	
	if GameManager.hideUI:
		$reticle.modulate.a = 0
		%speedLinesShader.visible = false
	else:
		$reticle.modulate.a = 1
		%speedLinesShader.visible = true
	
	if closest == null or height < 3 or coyoteTimeTarget:
		timeSinceNoTargets += 1
	else:
		timeSinceNoTargets = 0 
	if timeSinceNoTargets > 30 or isHeld:
		homingLookDown = false
	
	
	
	
	## Diving
	if %heightDetect.is_colliding():
		height = global_position.y - %heightDetect.get_collision_point().y
	else:
		height = 150
	deactivateDive = max(deactivateDive-1, 0)
	
	if Input.is_action_just_pressed("dive") and !%nearFloor.is_colliding() and !isHeld and deactivateDive == 0:
		var newSpd = clamp(height*-1.5 -10, -90, -10)
		#use max so you can't override it by diving mid dive
		heightWhenDiveBegun = max(global_position.y, heightWhenDiveBegun)
		
		linear_velocity.y = min(newSpd, linear_velocity.y)
		linear_velocity.x *= 0.5
		linear_velocity.z *= 0.5
		#print("height: ", height, " speed: ", newSpd, " points: ", 100*height )
		if diving == false:
			ScoreManager.give_points(50*height, 0, false, "DIVE")
		if height > 10:
			ScoreManager.give_points(0, 0, true) #only reset the timer if you're high up enough
			ScoreManager.play_trick_sfx("rare")
		if newSpd <= -75 and diving == false:
			ScoreManager.give_points(0, 5, true, "HIGH DIVE") #diving at capped height
			ScoreManager.play_trick_sfx("legendary")
		#Put you in tipspin position if you were spinning fast enough
		print("the transparency is ", %speedLines1.transparency)
		if %speedLines1.transparency < 0.8:
			print("yupp goodneough for me")
			global_rotation = Vector3(0,0,-90)
		diving = true #DIVING VARIABLE
		
		if timeSinceNoTargets > 0 and timeSinceNoTargets <= 16:
			printerr("DOVE DURING COYOTE TIME !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		print("DIVING, TIME SINCE NO TARGET: ", timeSinceNoTargets, " closest: ", closest, " last frame: ", closestLastFrame)
		
		
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
			if surfMode and not targetingRail:
				deactivateSurfMode()
			## Move the camera in freecam mode
			if legacyCamera == false:
				var hDir = Vector2(-$homing/raycast.target_position.z, -$homing/raycast.target_position.x)
				var oldAng = defaultCameraAngle.y
				var newAng = rad_to_deg(hDir.angle())
				var angleDiff = abs(wrap(oldAng-newAng, -180, 180))
				if angleDiff < 120: #don't rotate when behind you
					wrap_camera(oldAng, newAng)
					defaultCameraAngle.y = newAng
					
				
	
	
	#if get_contact_count() >= 1 and linear_velocity.y <= -5:
	#	if diving or homing:
	#		printerr("DIVING WOULD HAVE GOTTEN RESET BEFORE")
	if linear_velocity.y > -5: #otherwise dive can persist if you bounce 
		if diving or homing:
			print("RESETING DIVING")
			diveReboundTimer = 20
		diving = false
		homing = false
		
	
	#x0 when homing, x1 otherwise
	if !homing or linear_velocity.y > -25:
		gravity_scale = 1.5
	else:
		gravity_scale = 0.0
	#reduce damping so you don't slow down when diving large distances
	if homing or diving:
		linear_damp = 0.1
	else:
		linear_damp = 0.6
	
	##Speed smear
	if homing: 
		$homing/smear.visible = true
		var smearLength = global_position.distance_to(posLastFrame)
		#print(smearLength)
		$homing/smear.scale.z = smearLength * 0.4
	else:
		$homing/smear.visible = false
	
	## Influence direction of homing
	var lerpSpeed := 0.06
	if get_input_axis():
		lerpSpeed = 0.5
	
	%homingTarget.position.x = lerp(%homingTarget.position.x, 5 * Input.get_axis("left", "right"), lerpSpeed)
	%homingTarget.position.z = lerp(%homingTarget.position.z, 5 * Input.get_axis("forward", "back"), lerpSpeed)
	%homingArea.rotation_degrees.z = lerp(%homingArea.rotation_degrees.z, 28 * Input.get_axis("left", "right"), lerpSpeed)
	%homingArea.rotation_degrees.x = lerp(%homingArea.rotation_degrees.x, 28 * Input.get_axis("back", "forward"), lerpSpeed)
	#%homingArea.rotation_degrees.x = 25 * Input.get_axis("back", "forward")
	$homing/camRotation.global_rotation.y = %camFocus.global_rotation.y
	## Diving/homing end ##
	
	
	# bubble boost
	
	$bubbleBoost/MeshInstance3D.visible = bubbleMode
	
	if bubbleMode and height > 4:
		if Input.is_action_just_pressed("jump"):
			
			#turn momentum
			if get_input_axis():
				xVel = Vector2(linear_velocity.x, linear_velocity.z) 
				xVel = xVel.length()
				newVel = Vector3(0,0,-xVel)
				newVel = rotate_by_cam(newVel)
				newVel = Vector2(newVel.x, newVel.z)
				newVel = newVel.rotated(get_input_axis().angle()+PI/2)
				newVel = Vector3(newVel.x,0,newVel.y)
				linear_velocity = newVel 
			
			linear_velocity = linear_velocity.normalized() * 30
			linear_velocity.y = 2
			bubbleMode = false
			
			# cam turn
			if legacyCamera == false:
				var hDir = Vector2(-linear_velocity.z, -linear_velocity.x)
				var oldAng = defaultCameraAngle.y
				var newAng = rad_to_deg(hDir.angle())
				wrap_camera(oldAng, newAng)
				defaultCameraAngle.y = newAng
			
			
	
	
	
	
	
	
	
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
		ScoreManager.give_points(angular_velocity.length()*0.1,0,false, "SPEEN")
		
	
	
	
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
				ScoreManager.give_extra_combo_time(500)
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
		
	
	
	var surfSparkSpd
	var surfSparkRate
	######################
	##   Sign Surfing   ##
	######################
	if not surfMode:
		surfState = "Not surfing"
	var floor_normal = %canSurf.get_collision_normal().normalized() #deaulf value to avoid crash
	$sign_scraping.volume_linear = 0
	$skateboarding.volume_linear = 0
	if !$surfPivot/skateTricks.is_playing():
		%surfSparks.emitting = (surfMode and %surfRC3.is_colliding() and !skateboardSurf) or isRailGrinding
	$RemoteTransformSurf.update_rotation = isRailGrinding #stops the fish from rotating during railgrind
	
	railCooldown = max(0, railCooldown-1) #stops the game from crashing by entering 2 rails on the same frame
	
	
	if surfMode:
		##Particles
		surfSparkSpd = clamp( (trueSpeed.length()-5)*0.1 +1, 1, 5) #1 at 5, 5 at 45
		surfSparkRate = clamp( (trueSpeed.length()-5)*0.03, 0, 1) #0 at 5, 1 at 38
		
		$surfPivot/sparkPivot.rotation_degrees.y = 0
		if isRailGrinding:
			surfSparkSpd = max(surfSparkSpd, 2.5)
			surfSparkRate = max(surfSparkRate, 0.5)
			$surfPivot/sparkPivot.rotation_degrees.y = 45
		
		%surfSparks.speed_scale = surfSparkSpd
		%surfSparks.amount_ratio = surfSparkRate
		
		##Braking/Drifting
		if surfState == "Normal surfing" and Input.is_action_pressed("dive") and $surfPivot.global_transform.basis.y.y > 0.5:
			%brakingPivot.rotation_degrees.x = clamp(linear_velocity.length()*1.5,15, 45)
			#print(%brakingPivot.rotation_degrees.x)
			%surfSparks.emitting = true
			%surfSparks.speed_scale *= 2
			%surfSparks.amount_ratio *= 2
			if Input.is_action_just_pressed("jump"):
				print("KICKFLIP JUMP")
				$surfPivot/skateTricks.play("kick_flip")
				ScoreManager.give_points(2500, 0, false, "KICKFLIP")
				ScoreManager.play_trick_sfx("rare")
				
			elif $surfPivot/skateTricks.current_animation != "kick_flip":
				if !get_input_axis(): #slow down faster when not holding any direction keys
					apply_central_force(linear_velocity*-3)
				else:
					apply_central_force(linear_velocity*-1)
					
					#var moveDir = Vector2(linear_velocity.x, linear_velocity.z)
					#var keyDir = get_input_axis().normalized()
					#var drift = keyDir*moveDir.length()
					#linear_velocity.x = drift.x
					#linear_velocity.z = drift.y
					#var dotProd = moveDir.normalized().dot(drift.normalized())
					#if !$quickTurn.is_playing() and dotProd < 0.4: #if you turn more than 36«degrees
						#$quickTurn.play()
			
		else:
			%brakingPivot.rotation.x = 0
		
		if $surfPivot.global_transform.basis.y.y < 0.2 and %surfRC2.is_colliding():
			var worth = clamp(linear_velocity.length()*height, 0, 1000)
			ScoreManager.give_points(worth, 0, false, "WALLRIDE")
			ScoreManager.give_extra_combo_time(0.5)  #make combo timer 50% slower
			#print(worth)
		
		
		
		#audio
		if skateboardSurf:
			$skateboarding.volume_linear = clamp(linear_velocity.length()*0.015 -0.015, 0, 0.15)
			$skateboarding.pitch_scale = clamp(0.5 + linear_velocity.length()/30, 0.8, 2)
		else:
			$sign_scraping.volume_linear = clamp(linear_velocity.length()*0.025 -0.02, 0, 0.25)
			$sign_scraping.pitch_scale = clamp(0.5 + linear_velocity.length()/25, 0.5, 2)
		#print("v: ", $skateboarding.volume_linear, "  p: ", $skateboarding.pitch_scale)
		#print($skateboarding.pitch_scale)
		
		#print(linear_to_db(0.5))
		
		#leaning
		%fishPivot.visible = true
		%fishPivot.rotation = %homingArea.global_rotation #use the rotation of homing hitbox to lean
		var vec3 : Vector3 = %fishPivot.rotation
		%fishPivot.rotation = vec3.rotated(Vector3(0,1,0), -$surfPivot.rotation.y)
		%fishPivot.rotation *= -0.5
		
		#so he doesnt looks flat when facing directly up or down
		if abs($surfPivot.rotation_degrees.y) > 170 or abs($surfPivot.rotation_degrees.y) < 10:
			if surfRotationType == "":
				%fishPivot.rotation_degrees.y = -30 
		
		
		
		
		#landing sfx volume
		var surfJumpLastFrame = false
		if surfState == "Jumping":
			surfJumpLastFrame = true
		#bs so that we can know the speed you had BEFORE you landed
		fallSpeeds.append(linear_velocity.y)
		fallSpeeds.remove_at(0)
		#if linear_velocity.y < -1: 
		#	print(fallSpeeds,  " vol: ", snapped($skateLanding.volume_linear, 0.01))
		
		if isRailGrinding:
			surfState = "railGrinding"
			updateInputHistory()
		else:
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
					$skateboarding.volume_linear = 0
					updateInputHistory()
		
		if surfJumpLastFrame and surfState != "Jumping":
			if !$skateLanding.playing and linear_velocity.y < -1:
				$skateLanding.volume_linear = clamp(fallSpeeds[0]*-0.03 + 0.2, 0.4, 1.5)
				$skateLanding.play()
				print("PLAY LANDING ", $skateLanding.volume_linear, " fall speed: ", fallSpeeds[0])
				var force = linear_velocity
				force.y = 0
				#apply_central_impulse(force*$surfPivot.global_transform.basis.y.y)
				#print("applying impulse of force: ", force*$surfPivot.global_transform.basis.y.y*3)
		
		
		
		##Surfing or non-halfpipe jump
		if surfState != "Jumping" and linear_velocity.length() > 0.1 and surfState != "railGrinding":
			var vel_dir = linear_velocity.normalized()
			var forward = vel_dir.slide(floor_normal).normalized()
			var right = forward.cross(floor_normal).normalized()
			var newBasis = Basis(right, floor_normal, -forward).orthonormalized()
			$surfPivot.global_transform.basis = newBasis
			ScoreManager.reset_airspin()
			surfRotationType = ""
			inputHistory = ["","",""]
			
		elif surfState != "railGrinding": ##Rotating in the air
			
			if $surfPivot.global_transform.basis.y.y < 0.45 and isHalfPiping:
				if surfState == "Jumping" and linear_velocity.y > 20:
					if !$halfpipe.playing and %surfRC3.is_colliding():#play the sfx a little early so its timed better
						print("PLAY SFX IN ADVANCE")
						$halfpipe.play()
					
					if !%halfPipeCheck.is_colliding():
						surfRotationType = "clockwise"
						ScoreManager.give_points(5000, 0, true, "HALFPIPE")
						ScoreManager.play_trick_sfx("rare")
						isHalfPiping = false
						print("AUTO HALF PIPE SPIN")
			
			var curBasis = $surfPivot.global_transform.basis
			var spinSpeed = angular_velocity.length() * 0.06 * _delta * spinBoostBonus
			spinBoostBonus = max(spinBoostBonus-0.22, 1)
			
			if height > 10 and linear_velocity.y < 0 and surfRotationType == "":
				surfRotationType = "tumble"
			if surfRotationType == "tumble":
				#print("AIR TUMBLE")                                 #this adds a bit of non-rng randomness 
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
				if surfRotationType == "frontFlip":
					spinSpeed *= -1
				$surfPivot.global_transform.basis = curBasis.rotated(curBasis.x, spinSpeed)
				ScoreManager.airSpinAmount += abs(rad_to_deg(spinSpeed))
			if surfRotationType == "leftFlip" or surfRotationType == "rightFlip":
				if surfRotationType == "rightFlip":
					spinSpeed *= -1
				$surfPivot.global_transform.basis = curBasis.rotated(curBasis.z, spinSpeed)
				ScoreManager.airSpinAmount += abs(rad_to_deg(spinSpeed))
				
				
		
		
	
	#lose style points very quickly when not moving
	if trueSpeed.length() < 0.1 and !tiplanding and !isHeld:
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
	%parry.disabled = true
	$antiRotation.global_rotation.y = %camFocus.global_rotation.y #make anti rotation rotate with the camera
	
	if Input.is_action_just_pressed("FIsh") and !isHeld:
		$FIsh.play()
		$recordingManager.fishPressed = true
		if height > 6 and abs(linear_velocity.y) < 6 and fishCooldown > 60:
			GameManager.hitstop(20)
			ScoreManager.give_points(height*300, 5, true, "POSE FOR THE CAMERA")
			ScoreManager.give_extra_combo_time(80) #give you extra time
			ScoreManager.update_freshness(self)
			ScoreManager.tutorialChecklist["taunt"] += 1
			%parry.disabled = false
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
	var target = 0.5 - (trueSpeed.length()-25.0)*0.0125 #0.7 at <30 | 0.43 at 30 | 0.0 at 65
	if isHeld: #so it doesnt do it on the hook or eel
		target = 0.7
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
	var speed = global_position.distance_to(posLastFrame)*60
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
	
	trueSpeed = (global_position-posLastFrame) * 60
	posLastFrame = global_position
	
	#DEBUG_INFO
	%debugLabel2.text = str("global_pos: ", global_position, "\n",
	"true speed: ", snapped(trueSpeed.length(), 0.01)," ",snapped(trueSpeed, Vector3(0.01,0.01,0.01)),"\n",
	"velocity: ", snapped(linear_velocity.length(), 0.01)," ",snapped(linear_velocity, Vector3(0.01,0.01,0.01)),"\n",
	"spin: ", snapped(angular_velocity.length(), 0.01), " ", snapped(angular_velocity, Vector3(0.01,0.01,0.01)), "\n",
	"current railgrind: ", currentRailObj, "
	surf jump: ", surfJumpHolding, "
	surf state: ", surfState, "
	Rotation Type: ", surfRotationType, "
	last input ago: ", timeSinceLastInput, "
	input hitory: ", inputHistory, "
	isHalfPiping: ", isHalfPiping, "
	floor normal: ", floor_normal, "
	y.y basis: ", $surfPivot.global_transform.basis.y.y, "
	spinBoostBonus: ", spinBoostBonus, "\n",
	"spark speed: ", %surfSparks.speed_scale, "\n",
	"spark rate: ", %surfSparks.amount_ratio, "\n",)
	
	
	var closestName = "null"
	if closest:
		closestName = str(closest.name, " (", closest.get_parent().name, ")")
	
	%debugLabel.text = str(
	"fov: ", %cam.fov, "\n",
	"height: ", snapped(height, 0.01), " above: ", %heightDetect.get_collider(), "\n",
	"linear velocity: ", snapped(linear_velocity.length(), 0.1)," ",snapped(linear_velocity, Vector3(0.1,0.1,0.1)), "\n",
	"angular velocity: ", snapped(angular_velocity.length(), 0.1), " ", snapped(angular_velocity, Vector3(0.1,0.1,0.1)), "\n",
	"diving: ", diving, "\n",
	"camera rc: ", get_collider_name(%ceilDetect), "\n",
	"target: ", get_collider_name($homing/raycast), "\n",
	"closest: ",  closestName, "\n",
	"closestLastFrame: ", closestLastFrame, "\n",
	"timeSinceNoTargets: ", timeSinceNoTargets, "\n",
	"homingLookDown: ", homingLookDown, "\n",
	"gravity scale: ", gravity_scale, "\n", 
	"position ", global_position, "\n",
	"CameraAngle: ", %camFocus.rotation_degrees, "\n",
	"CameraTarget: ", defaultCameraAngle, "\n",
	"diveReboundTimer: ", diveReboundTimer, "\n",
	"dive height: ", heightWhenDiveBegun, " - gp.y: ", snapped(global_position.y, 0.1), " = ",
	" rebound strength: ", snapped(dive_rebound_strength(), 0.1), "\n",
	#"homeDir: ", rad_to_deg(Vector2(-$homing/raycast.target_position.z, -$homing/raycast.target_position.x).angle()) 
	)
	
	



#(I have to put the camera inside process because it needs to be synced up with the screen
#otherwise, in physics process theres a delay, even when the cam rate is set to be instant)
func _process(_delta):
	
	##Training mode flashing
	#var flashColor = Color("ffffff")
	#
	#if height > 6 and abs(linear_velocity.y) < 6 and fishCooldown > 60 and !isHeld:
		#flashColor = Color("ff00ff") #taunt
	#if !%nearFloor.is_colliding() and timeSinceJump > 20 and %floorDetection.is_colliding():
		#flashColor = Color("0000ff") 
	#if diveReboundTimer >= 0 and timeSinceJump > 20 and %floorDetection.is_colliding():
		#flashColor = Color("ffff00")
	#$pivotUpper/upperBody.modulate = flashColor
	#$pivotUpper/pivotHead/head.modulate = flashColor
	#$pivotLower/lowerBody.modulate = flashColor
	#$pivotLower/pivotTail/tail.modulate = flashColor
	
	################
	##   CAMERA   ##
	################
	
	#fov
	%cam.fov = lerp(%cam.fov, 85.0, 0.1)   
	if %cam.fov > 84.99:
		%cam.fov = 85
	
	
		## CONTROLS ##
	if legacyCamera:
		## CLASSIC CAMERA CONTROLS
		if Input.is_action_pressed("camera") and !cameraOverride:
			if get_input_axis():
				cameraOverride = true
			if get_input_axis().x != 0:
				var LR = Input.get_axis("right", "left")
				targetCamAngle.y = 40 * LR
				targetCamOffset = Vector3(-3.5*LR, 0.58, 1.02)
			elif Input.is_action_pressed("forward"):
				targetCamAngle.x += 40
				targetCamOffset = Vector3(0, 2.3, -1.5)
			elif Input.is_action_pressed("back"):
				targetCamAngle.x -= 15
				targetCamOffset = Vector3(0,0,5)
		
		if !Input.is_action_pressed("camera"): #reset camera when you let go of C
			cameraOverride = false
		
	else:
		## NEW CAMERA CONTROLS
		cameraOverride = false
		
		if Input.is_action_just_pressed("camera") and Input.is_action_pressed("left"):
		#or Input.is_action_pressed("camera") and Input.is_action_just_pressed("left"):
			defaultCameraAngle.y += 45
			reset_vertical_camera()
			autoCamTurning = false
			if defaultCameraAngle.y >= 180: #wrap angles
				%camFocus.rotation_degrees.y -= 360
				defaultCameraAngle.y -= 360
			
		
		if Input.is_action_just_pressed("camera") and Input.is_action_pressed("right"):
		#or Input.is_action_pressed("camera") and Input.is_action_just_pressed("right"):
			defaultCameraAngle.y -= 45
			reset_vertical_camera()
			autoCamTurning = false
			if defaultCameraAngle.y <= -180: #wrap angles
				%camFocus.rotation_degrees.y += 360
				defaultCameraAngle.y += 360
			
		
		#center camera
		var hDir = Vector2(-trueSpeed.z, -trueSpeed.x)
		var newAng = rad_to_deg(hDir.angle())
		if Input.is_action_just_pressed("camera") and !get_input_axis():
			autoCamTurning = !autoCamTurning
			VcameraSetting = 1
			if hDir.length() > 4: #instantly turn camera at first (if not standing still)
				wrap_camera(defaultCameraAngle.y, newAng)
				defaultCameraAngle.y = newAng
				VcameraSetting = 1
			
		$UI/camIcon/ColorRect/manual.visible = !autoCamTurning
		$UI/camIcon/ColorRect/auto.visible = autoCamTurning
		$UI/camIcon/ColorRect.visible = !GameManager.hideUI
		#Auto cam rotation
		if autoCamTurning and hDir.length() > 4:
			wrap_camera(defaultCameraAngle.y, newAng, true)
			var turningSpd = clamp(hDir.length()*0.002, 0, 0.1) #0.02 at spd=10, 0.1 at spd=50
			#print("lerping from ", snapped(defaultCameraAngle.y, 0.01), " to ", snapped(newAng, 0.01), " @ ", snapped(turningSpd, 0.01) )
			defaultCameraAngle.y = lerp(defaultCameraAngle.y, newAng, turningSpd)
			
		
		
		
		
		#Vertical camera control
		#don't allow if left or right is pressed so you can spam diagonally
		if !Input.is_action_pressed("right") and !Input.is_action_pressed("left"):
			if Input.is_action_just_pressed("camera") and Input.is_action_pressed("back"):
			#or Input.is_action_pressed("camera") and Input.is_action_just_pressed("back"):
				VcameraSetting = clamp(VcameraSetting+1, 0, 2)
				homingLookDown = false
			
			if Input.is_action_just_pressed("camera") and Input.is_action_pressed("forward"):
			#or Input.is_action_pressed("camera") and Input.is_action_just_pressed("forward"):
				VcameraSetting = clamp(VcameraSetting-1, 0, 2)
				homingLookDown = false
		
		if VcameraSetting == 0: #look up
			defaultCameraAngle.x = 10
			defaultCameraOffset = Vector3(0, 2.3, 0)
		else: #1 or 2
			defaultCameraOffset = Vector3(0, 0.58, 0) #default
		if VcameraSetting == 1: 
			defaultCameraAngle.x = -30
		if VcameraSetting == 2:         #top down
			defaultCameraAngle.x = -70
			defaultCameraDistance = 8
		else:
			defaultCameraDistance = 7# 0 or 1
		
		#Railgrind camera
		if isRailGrinding and currentRailObj:
			if currentRailObj.overrideCamDistance != 0:
				defaultCameraDistance = currentRailObj.overrideCamDistance
			
			#1=straight up, 0=sideways, -1=fully upside down
			if currentRailObj.autoUpDown:
				var upsideDownness = $surfPivot.global_transform.basis.y.y 
				defaultCameraAngle.x = -35 * upsideDownness
				defaultCameraOffset.y = 0.8 * upsideDownness
			if currentRailObj.dynamicCamera and autoCamTurning:
				var offset = currentRailObj.get_graph_value()
				print("offset: ",  offset, " progress: ", currentRailObj.progress_ratio)
				newAng += offset
				wrap_camera(defaultCameraAngle.y, newAng, true)
				defaultCameraAngle.y = lerp(defaultCameraAngle.y, newAng, 0.3)
		
	
	
	#print($detectCamSwitch.get_overlapping_areas())
	
	## inside camera controller areas
	%camFocus.top_level = false
	if $detectCamSwitch.has_overlapping_areas():
		
		
		#print($detectCamSwitch.get_overlapping_areas())
		var area = $detectCamSwitch.get_overlapping_areas()[-1]
		targetCamAngle = area.newCameraAngle
		targetCamOffset = area.newCameraOffset
		targetCamDist = area.newCameraDistance
		if area.target != null:
			%camFocus.top_level = true
			%camFocus.global_position = %camFocus.global_position.lerp(area.target.global_position, camSpeed)
		camSpeed = area.rate
		cameraOverride = true #so you cant move the cam manually in switch areas
	elif cameraOverride == false:
		#var mouse = Input.get_last_mouse_velocity() #hack tessting mouse controls
		#defaultCameraAngle.y -= mouse.x*0.001
		#defaultCameraAngle.x -= mouse.y*0.001
		targetCamAngle = defaultCameraAngle #default camera settings
		targetCamOffset  = defaultCameraOffset
		targetCamDist = defaultCameraDistance
		camSpeed = 0.2
		#lower camera when close to a ceiling
		if %ceilDetect.is_colliding():                                   #clamp min to 1
			var dist = max(%ceilDetect.get_collision_point().y - global_position.y, 1)
			targetCamOffset.y = 0.58 - (4 - dist)
		
	 
	
	
	##Slowly pan the camera towards the desired location
	%camFocus.rotation_degrees = %camFocus.rotation_degrees.lerp(targetCamAngle, camSpeed) #angle of focus
	if %camFocus.top_level == false: #not if the controller has a custom camera
		%camFocus.position = %camFocus.position.lerp(targetCamOffset, camSpeed) #Position of focus
	%cam.position.z = lerp(%cam.position.z, targetCamDist, camSpeed) #Distance from focus
	#%camFocus.global_position = camLockOnTarget.global_position
	var targetTilt = 0.0
	if (homingLookDown) and !$detectCamSwitch.has_overlapping_areas():
		targetTilt = -24.0
	%cam.rotation_degrees.x = lerp(%cam.rotation_degrees.x, targetTilt, camSpeed)
	

##Rotates camFocus by 360 degrees if the current camera and target angle crosses over the -180\180 point
##This function uses degrees, make sure you're not using radians
func wrap_camera(oldAngle:float, newAngle:float, wrapDefaultCamAngleY:bool=false):
	if oldAngle-newAngle < -180:
		%camFocus.rotation_degrees.y += 360
		if wrapDefaultCamAngleY:
			defaultCameraAngle.y += 360
	if oldAngle-newAngle > 180:
		%camFocus.rotation_degrees.y -= 360
		if wrapDefaultCamAngleY:
			defaultCameraAngle.y -= 360
		

#reset the cam vertical position UNLESS
#you're holding up while looking up, or holding down while looking down
func reset_vertical_camera():
	print("vcam: ", VcameraSetting, " y input: ", get_input_axis().y)
	if VcameraSetting == 0 and Input.is_action_pressed("forward"):
		return
	if VcameraSetting == 2 and Input.is_action_pressed("back"):
		return
	VcameraSetting = 1



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
	#Pivot point when braking
	%brakingPivot.position.z = 0.75
	$surfPivot/brakingPivot/counterPivot.position.z = -0.75
	if sprite.get_file().begins_with("tri_"):
		%brakingPivot.position.z = 0.2
		$surfPivot/brakingPivot/counterPivot.position.z = -0.2
	if  sprite.get_file().contains("piano"):
		PianoManager.activate = true
	%surfSignUnder.visible = sprite.get_file().contains("skateBoard") #skateboard underside
	%surfSign.double_sided = !%surfSignUnder.visible
	$surfPivot.visible = true
	%pivotUpper.visible = false
	%pivotLower.visible = false
	$shadowMesh.visible = false
	$collision.set_deferred("disabled", true)
	$collisionSphere.set_deferred("disabled", false)
	if height < 0.6:
		global_position.y += 0.6 - height
	ScoreManager.give_extra_combo_time(80) #give you extra time
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
	PianoManager.activate = false
	$collision.set_deferred("disabled", false)
	$collisionSphere.set_deferred("disabled", true)
	skateboardSurf = false
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
	if timeSinceLastInput == 1: #so you can't just spam keys randomly super fast
		return
	if Input.is_action_just_pressed("forward"):
		inputHistory.append("up")
	elif Input.is_action_just_pressed("back"):
		inputHistory.append("down")
	elif Input.is_action_just_pressed("left"):
		inputHistory.append("left")
	elif Input.is_action_just_pressed("right"):
		inputHistory.append("right")
	
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
		if surfRotationType != "frontFlip":
			surfRotationType = "backFlip"
			newTrick = true
	if inputHistory == ["up", "down", "up"]:
		if surfRotationType != "backFlip":
			surfRotationType = "frontFlip"
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
		if isRailGrinding:
			if !$surfPivot/skateTricks.is_playing() or $surfPivot/skateTricks.current_animation_position > 0.8:
				ScoreManager.give_points(1200, 0, true, "INPUT COMBO")
				currentRailObj.mountingSpeed += 5
			else:
				ScoreManager.give_points(300, 0, true, "INPUT COMBO")
			$surfPivot/skateTricks.play("RESET")
			$surfPivot/skateTricks.play(surfRotationType)
			$spin_high.play()
			surfRotationType = ""
			
		else: ##when not railgrinding
			if angular_velocity.length() < 80:
				angular_velocity *= 80/angular_velocity.length()
			
			if surfRotationType == prevRotation: 
				ScoreManager.give_points(500, 0, true, "INPUT COMBO")
				if angular_velocity.length() < 180:
					angular_velocity *= 1.05 #doing the same rotation twice in a row
				spinBoostBonus = 2.7
				$spin_low.play()
			else:
				ScoreManager.give_points(800, 0, true, "INPUT COMBO")
				if angular_velocity.length() < 220:
					angular_velocity *= 1.13 #doing a different rotation
				spinBoostBonus = 3.8
				$spin_high.play()
			
		



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
	var y = Input.get_axis("forward", "back")
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
	pass
	#var skin = preload("res://Skins/lemmedoitfoyew.png")
	#$pivotUpper/upperBody.texture = skin
	#$pivotUpper/pivotHead/head.texture = skin
	#$pivotLower/lowerBody.texture = skin
	#$pivotLower/pivotTail/tail.texture = skin
	

func force_position(newPos : Vector3):
	global_position = newPos
	#if not surfMode: #when surfing, this causes some weird divide by 0 glitch 
	linear_velocity = Vector3(0.001,0.001,0.001) 
	angular_velocity = Vector3(0.001,0.001,0.001)

func get_closest_target():
	var crabs = %homingArea.get_overlapping_areas()

	var detectedCrabs = []
	
	## Weed out all of the crabs behind a walls
	for crab in crabs:
		var direction = global_position.direction_to(crab.global_position)
		$homing/raycast.target_position = direction*5
		$homing/raycast.force_raycast_update()
		if $homing/raycast.get_collider() == crab:
			#Ignore railgrinds when not in surf mode
			if crab.get_parent() is railGrind and not surfMode:
				continue
			#ignore everything BUT railgrinds when in railgrinding
			if crab.get_parent() is not railGrind and isRailGrinding:
				continue
			
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

func set_offscreen_reticle(center, posBefore, closest):
	$reticle/offScreenArrow.visible = true
	$reticle/icon.visible = true
	var angle = center.angle_to_point(posBefore)
	var edge_dir = Vector2(cos(angle), sin(angle))
	
	var t_x = INF
	var t_y = INF #prevents division by 0
	if abs(edge_dir.x) > 0.0001:
		t_x = center.x / abs(edge_dir.x)
	if abs(edge_dir.y) > 0.0001:
		t_y = center.y / abs(edge_dir.y)
	var t = min(t_x, t_y)
	$reticle.position = center+(edge_dir*t*0.75)
	$reticle/offScreenArrow.rotation = angle
	$reticle/icon.frame = 0
	if closest.get_parent() is boostRing:
		$reticle/icon.frame = 1
	if closest.get_parent() is enemy:
		$reticle/icon.frame = 2
	if closest.get_parent() is jellyfish:
		$reticle/icon.frame = 3
	if closest.get_parent() is hook:
		$reticle/icon.frame = 4
	if closest.get_parent() is bowlingPins:
		$reticle/icon.frame = 5
	if closest.get_parent() is sign:
		$reticle/icon.frame = 6
	if closest.get_parent() is Mine:
		$reticle/icon.frame = 7
	if closest.get_parent() is railGrind:
		$reticle/icon.frame = 8
	if closest.get_parent() is Target:
		$reticle/icon.frame = 9
	

func set_jump_meter_pos(newPos: Vector2):
	$UI/surfJump.global_position = newPos
	

func play_skate_anim(anim_name : String):
	$surfPivot/skateTricks.play(anim_name)

func play_shock_wave():
	if !$UI/shockWaveAnim.is_playing():
		$UI/shockWaveAnim.play("shockwave")
		$aura.play()
		$shockwave.play()

func setJumpPreview(value : bool):
	$UI/jumpPreview.visible = value

func forceMakeCameraCurrent():
	%cam.current = true

##So that we can stop renering the world when the game is paused, causing a HUGE performance boost
func should_camera_render(value: bool):
	%cam.set_cull_mask_value(1, value)
	%cam.set_cull_mask_value(2, value)

func dive_rebound_strength():
	return max(heightWhenDiveBegun-global_position.y, 10)
