@tool
extends Node3D

#script for rotating objects

###
@export var xRotation : bool = false
@export var xRandom : bool = false
@export var yRotation : bool = false
@export var yRandomDirection : bool = false

var randomOfX = 1
###


var rotationSpeed = 0.01
var rotationDirection = 1

func _ready() -> void:
	
	#randomizes x and y rotation
	if xRandom:
		randomOfX = randi_range(1, 2)
	
	if yRandomDirection and randi_range(1, 2) == 1:
		rotationDirection = -1
	
	#randomly flip upside down
	%Rock.rotation_degrees.x = 180*randi_range(0, 1)
	#randomize speed
	rotationSpeed = randf_range(0.3, 0.6)
	#randomize starting position
	%Rock.rotation.y = randf_range(-PI, PI)
	
	### randomizes the aniamtion start
	%AnimationPlayer.play("Floating")
	%AnimationPlayer.seek(randf_range(0, 7))
	###
	
	
	
func _process(_delta: float) -> void:
	
	
	###
	if yRotation:
		%Rock.rotation_degrees.y += rotationSpeed * rotationDirection
	
	###
	if xRotation and randomOfX == 1:
		%Rock.rotation.x += 0.01
	elif xRotation and randomOfX == 2:
		%Rock.rotation.x -= 0.01
	###
	
	
	#%Rock.mesh = currentMesh

  
