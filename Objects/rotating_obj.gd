extends MeshInstance3D

#script for rotating objects

@export var xRotation : bool = false
@export var xRandom : bool = false
@export var yRotation : bool = false
@export var yRandom : bool = false

var randomOfX = 1
var randomOfY = 1


func _ready() -> void:
	#randomizes x and y rotation
	if xRandom:
		randomOfX = randi_range(1, 2)
	
	if yRandom:
		randomOfY = randi_range(1, 2)
	
	%AnimationPlayer.play("Floating")


func _process(_delta: float) -> void:
	
	
	###
	if yRotation and randomOfY == 1:
		rotation.y += 0.01
	elif yRotation and randomOfY == 2:
		rotation.y -= 0.01
	###
	
	###
	if xRotation and randomOfX == 1:
		rotation.x += 0.01
	elif xRotation and randomOfX == 2:
		rotation.x -= 0.01
	###


  
