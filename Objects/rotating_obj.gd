@tool
extends Node3D

#script for rotating objects

###
@export var xRotation : bool = false
@export var xRandom : bool = false
@export var yRotation : bool = false
@export var yRandom : bool = false

var randomOfX = 1
var randomOfY = 1
###

###
@export_file("*.obj") var currentMesh: String


func _ready() -> void:
	
	#randomizes x and y rotation
	if xRandom:
		randomOfX = randi_range(1, 2)
	
	if yRandom:
		randomOfY = randi_range(1, 2)
	
	
	
	### randomizes the aniamtion start
	%AnimationPlayer.play("Floating")
	%AnimationPlayer.seek(randf_range(0, 5))
	###
	
	
	
func _process(_delta: float) -> void:
	
	
	###
	if yRotation and randomOfY == 1:
		%Rock.rotation.y += 0.01
	elif yRotation and randomOfY == 2:
		%Rock.rotation.y -= 0.01
	###
	
	###
	if xRotation and randomOfX == 1:
		%Rock.rotation.x += 0.01
	elif xRotation and randomOfX == 2:
		%Rock.rotation.x -= 0.01
	###
	
	
	#%Rock.mesh = currentMesh

  
