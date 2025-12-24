extends Node3D

###########################################################
## We'll use this fish when racing against ghosts.
## It doesnt have any movement code and will just follow the position and angle
## data stored in the demo files.
## We can also use this fish as a puppet to use in animatons with JFG
#######################################################

@export var skinPreviewMode : bool = false


const BASE_SPIN_SPEED : float = 0.05
var spinSpeed : float = BASE_SPIN_SPEED  #makes it so you can spin the preview with the mouse


var flopTimer := 0

func _physics_process(_delta):
	## Flop Animation
	var amp = 1 #max(angular_velocity.length() * 0.18, linear_velocity.length())
	if !skinPreviewMode:
		flopTimer += 1 
		$pivotUpper.rotation_degrees.z = sin(flopTimer * 0.3) *  3*clamp(amp, 1, 10)
		$pivotLower.rotation_degrees.z = sin(flopTimer * 0.3) * -3*clamp(amp, 1, 10)
		$pivotUpper/pivotHead.rotation_degrees.z = sin(flopTimer * 0.3) *  6*clamp(amp, 1, 10)
		$pivotLower/pivotTail.rotation_degrees.z = sin(flopTimer * 0.3) *  -6*clamp(amp, 1, 10)  
	else:
		rotate_y(spinSpeed)
		#slow down over time
		if spinSpeed >= 0:
			spinSpeed = move_toward(spinSpeed, BASE_SPIN_SPEED, 0.01)
		else:
			spinSpeed = move_toward(spinSpeed, -BASE_SPIN_SPEED, 0.01)
			
		## Skip when its facing the camera due to a weird visual bug and
		## also so that its always visible
		if rotation_degrees.y > 87 and rotation_degrees.y < 93:
			if spinSpeed >= 0:
				rotation_degrees.y = 93
			else:
				rotation_degrees.y = 87
		if rotation_degrees.y > -93 and rotation_degrees.y < -87:
			if spinSpeed >= 0:
				rotation_degrees.y = -87
			else:
				rotation_degrees.y = -93
		
	
	

## Set the skin using an image directly
func set_skin(image : CompressedTexture2D):
	$pivotUpper/upperBody.texture = image
	$pivotUpper/pivotHead/head.texture = image
	$pivotLower/lowerBody.texture = image
	$pivotLower/pivotTail/tail.texture = image

## Set the skin using the ID of one of the skins in the Database
func quick_set_skin(id: int):
	set_skin(GameManager.database.get_skin_data(wrap(id, 0, GameManager.database.skins.size())).skin)
