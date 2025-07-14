@icon("res://icons/dialogue.png")
class_name Dialogue extends Resource

##Temporarily switch to a new camera during the dialogue sequence
@export_node_path("Camera3D") var cameraOverride : NodePath
##Automatically starts the textbox when entering the area without prompting first
@export var automaticStart : bool = false
##Pause the fish during the textbox, leave off for tutorials
@export var pauseGame : bool = true
##The textbox wont disapear after reaching the last textbox, used for the tutorial. 
##This also makes it so this dialogue can only run once and then never again.
@export var keepOnScreenAfterEnd : bool = false
##List of all the textboxes within this dialogue sequence
@export var messages : Array[textBoxSettings]
