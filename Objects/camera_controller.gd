@tool
@icon("res://icons/cam_areas.png")
class_name CameraController
extends Area3D

##The angle that the fish's "camFocus" node will get
@export var newCameraAngle : Vector3 = Vector3(-30, 0, 0)

##The offset that the camera focus point will have from the center of the fish
@export var newCameraOffset : Vector3 = Vector3(0, 0.58, 0)

##How far away the camera is from the focus
@export var newCameraDistance : float = 6.0

##Put a node in here and the camera will lock on to it
@export var target : Node

##Rate at which the camera will reach its new position and angle. 
##A value of 0.5 means that every frame the camera will travel 50% of the remaining way. 
##Use a value of 1.0 for instant transitions
@export_range(0, 1, 0.01) var rate = 0.2

@onready var offset = $offset
@onready var cam_rotation = $offset/camRotation
@onready var camera = $camera
@onready var cam_pivot = $offset/camRotation/camPivot



func _ready():
	collision_layer = 8 #layer 4
	collision_mask = 0
	if !Engine.is_editor_hint(): #when playing the game
		if !get_tree().debug_collisions_hint: 
			visible = false
		else:
			set_debug_visuals() #if "visible collision shapes" is on

func _process(_delta):
	if Engine.is_editor_hint():
		set_debug_visuals()
		

func set_debug_visuals():
	offset.position = newCameraOffset
	cam_rotation.rotation_degrees = newCameraAngle
	cam_rotation.scale.z = newCameraDistance
	camera.global_position = cam_pivot.global_position
	camera.rotation = cam_rotation.rotation
	newCameraAngle += rotation
	rotation = Vector3.ZERO
