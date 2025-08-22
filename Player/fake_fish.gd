extends Node3D

###########################################################
## We'll use this fish when racing against ghosts.
## It doesnt have any movement code and will just follow the position and angle
## data stored in the demo files.
## We can also use this fish as a puppet to use in animatons with JFG
#######################################################


var flopTimer := 0

func _ready():
	pass



func _process(_delta):
	## Flop Animation
	var amp = 0 #max(angular_velocity.length() * 0.18, linear_velocity.length())
	flopTimer += 1 
	$pivotUpper.rotation_degrees.z = sin(flopTimer * 0.3) *  3*clamp(amp, 1, 10)
	$pivotLower.rotation_degrees.z = sin(flopTimer * 0.3) * -3*clamp(amp, 1, 10)
	$pivotUpper/pivotHead.rotation_degrees.z = sin(flopTimer * 0.3) *  6*clamp(amp, 1, 10)
	$pivotLower/pivotTail.rotation_degrees.z = sin(flopTimer * 0.3) *  -6*clamp(amp, 1, 10)  
