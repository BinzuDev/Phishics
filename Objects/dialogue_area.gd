@icon("res://icons/dialogue_area.png")
extends Area3D


@export var dialogue : Dialogue

var isInside := false
var coolDown := 0
var alreadyRan := false

func _ready():
	if !dialogue:
		printerr("you forgot to fill the dialogue export!!!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !dialogue:
		return
	
	if !DialogueManager.isRunning:
		if dialogue.cameraOverride:
			get_node(dialogue.cameraOverride).current = false
		coolDown += 1
		if coolDown > 10 and !has_overlapping_bodies():
			isInside = false
			coolDown = 0
	
	if dialogue.runOnlyOnce and alreadyRan:
		return
	
	if has_overlapping_bodies():
		if dialogue.automaticStart:
			if !isInside:
				isInside = true
				start_dialogue()
		else:
			if Input.is_action_just_pressed("confirm") and !DialogueManager.isRunning:
				start_dialogue()
	
	
	

func start_dialogue():
	#Stops you from accidentaly restarting dialogue when spamming
	if DialogueManager.coolDown > 20 or dialogue.automaticStart:
		if dialogue.cameraOverride:
			get_node(dialogue.cameraOverride).current = true
		DialogueManager.start_dialogue_sequence(dialogue)
		alreadyRan = true
	


func _on_body_exited(body):
	DialogueManager.show_prompt(false)


func _on_body_entered(body):
	if !dialogue.automaticStart:
		DialogueManager.show_prompt(true)
