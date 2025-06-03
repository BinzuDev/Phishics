@icon("res://icons/cam_areas.png")
class_name CameraController
extends Area3D

##The angle that the fish's "camFocus" node will get
@export var newCameraAngle : Vector3 = Vector3(-30, 0, 0)

##The offset that the camera focus point will have from the center of the fish
@export var newCameraOffset : Vector3 = Vector3(0, 0.58, 0)

##How far away the camera is from the focus
@export var newCameraDistance : float = 5.2

##Put a node in here and the camera will lock on to it
@export var target : Node

##Rate at which the camera will reach its new position and angle. 
##A value of 0.5 means that every frame the camera will travel 50% of the remaining way. 
##Use a value of 1.0 for instant transitions
@export_range(0, 1, 0.01) var rate = 0.2


func _ready():
	collision_layer = 8 #layer 4
	collision_mask = 0
