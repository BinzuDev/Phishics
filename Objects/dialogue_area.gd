@icon("res://icons/dialogue_area.png")
class_name DialogueArea extends Area3D


@export var dialogue : Dialogue

var isInside := false
var coolDown := 0
var alreadyRan := false
var fish : player

func _ready():
	fish = get_tree().get_first_node_in_group("player")
	if !dialogue:
		printerr("you forgot to fill the dialogue export!!!")
	if !get_child(0):
		printerr("dialogue area \"", name, "\" doesn't have a collisionShape!")
	elif get_child(0) is not CollisionShape3D:
		printerr("the first child of ", name, " is ", get_child(0), ", which is NOT a collision shape! The first child NEEDS to be the collisionshape because of hardcoded stuff.")
		process_mode = Node.PROCESS_MODE_DISABLED
	


func _physics_process(_delta: float) -> void:
	if !dialogue:
		return
	
	if !DialogueManager.isRunning:
		#if dialogue.cameraOverride:
		#	get_node(dialogue.cameraOverride).current = false
		coolDown += 1
		if coolDown > 10 and !has_overlapping_bodies():
			isInside = false
			coolDown = 0
	
	if dialogue.runOnlyOnce and alreadyRan:
		return
	
	if has_overlapping_bodies() and !fish.isRailGrinding:
		if dialogue.automaticStart:
			if !isInside:
				isInside = true
				start_dialogue()
		else:
			get_child(0).scale = Vector3(1.30,1.30,1.30)
			#get_child(0).reset_physics_interpolation()
			if Input.is_action_just_pressed("confirm") and !DialogueManager.isRunning:
				start_dialogue()
		
	
	

func start_dialogue():
	#Stops you from accidentaly restarting dialogue when spamming
	if DialogueManager.coolDown > 20 or dialogue.automaticStart:
		#if dialogue.cameraOverride:
		#	get_node(dialogue.cameraOverride).current = true
		DialogueManager.currentDialogueOwner = get_parent()
		DialogueManager.currentDialogueArea = self
		DialogueManager.start_dialogue_sequence(dialogue)
		alreadyRan = true
	


func _on_body_exited(body):
	if !dialogue.automaticStart:
		DialogueManager.show_prompt(false)
		get_child(0).scale = Vector3(1,1,1)


func _on_body_entered(body):
	if body is player:
		if body.isRailGrinding == false: #dialogues can be really weird during railgrind
			if !dialogue.automaticStart:
				print(dialogue.promptType)
				DialogueManager.show_prompt(true, dialogue.promptType)
