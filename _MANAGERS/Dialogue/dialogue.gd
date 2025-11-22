@icon("res://icons/dialogue.png")
class_name Dialogue extends Resource

##Temporarily switch to a new camera during the dialogue sequence
@export_node_path("Camera3D") var cameraOverride : NodePath
##Automatically starts the textbox when entering the area without prompting first
@export var automaticStart : bool = false
##Pause the fish during the textbox, leave off for tutorials
@export var pauseGame : bool = true
##The textbox wont disapear after reaching the last textbox, used for the tutorial. 
@export var keepOnScreenAfterEnd : bool = false
##This makes it so the dialogue can only run once and then never again.
@export var runOnlyOnce : bool = false
##This hides and pauses the style system during the dialogue. If this is on, it'll unpause the style system EVEN if it was already paused before the dialogue.
@export var pauseStyleSystem : bool = false
##Plays this sound effect every time the dialogue progresses
@export_node_path("AudioStreamPlayer", "AudioStreamPlayer3D") var speechSFX : NodePath
##List of all the textboxes within this dialogue sequence
@export var messages : Array[textBoxSettings]
##Run code after closing the textbox. NOTICE: this code doesn't run "from" anywhere, so you don't have access to any Node functions.
##You do still have access to all the global manager scrips. 
##If you want to access the parent of the DialogueArea object that started this textbox, use DialogueManager.currentDialogueOwner.
##EX: if the Dialogue area is a direct child of the root level node, it will return the level node.
##WARNING: DO NOT USE ENTER! Seperate the lines of code with a ";" and a space.
@export_multiline var codePostDialogue : String
