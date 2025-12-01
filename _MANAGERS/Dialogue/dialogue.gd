@icon("res://icons/dialogue.png")
class_name Dialogue extends Resource

##Temporarily switch to a new camera during the dialogue sequence
@export_node_path("Camera3D") var cameraOverride : Array[NodePath]
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
##If the prompt should say "talk" or "read"
@export_enum("Talk", "Read") var promptType : String = "Talk"
##List of all the textboxes within this dialogue sequence
@export var messages : Array[textBoxSettings]
##Run custom code after closing the textbox.[br] 
##[b]NOTICE[/b]: this code doesn't run "[i]from[/i]" anywhere, so you don't have access to any Node functions.[br]
##Here's how to access various nodes:[br]
##    ● Current dialogueArea node: DialogueManager.currentDialogueArea[br]
##    ● Current dialogueArea's parent node: DialogueManager.currentDialogueOwner[br]
##    ● Current scene: GameManager.get_current_scene()[br]
##[color=orange]WARNING: DO NOT USE ENTER![/color] Seperate the lines of code with a ";" and a space.
@export_multiline var codePostDialogue : String
