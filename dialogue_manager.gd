extends Node

var text := ""
var timer := 0
var char := 0
var finished := true
var textBoxIndex := 0
var currentDialogue
var isRunning := false
var coolDown := 0

func _ready():
	$textBoxControl.visible = false
	$enterTip.visible = false

func show_prompt(state:bool = true):
	$enterTip.visible = state


func _process(_delta):
	if !$textBoxControl.visible: #this is at the start so it waits an extra frame so you cant
		isRunning = false        #start a dialogue with the same input used to end another one
	
	$enterTip/Control.visible = !isRunning #dont show prompt if textbox active
	%confirm.visible = finished and isRunning
	if currentDialogue:
		if textBoxIndex+1 == currentDialogue.messages.size() and currentDialogue.keepOnScreenAfterEnd:
			%confirm.visible = false #dont show confirm prompt on last textbox with keepOnScreen
			if finished:
				textBoxIndex += 1
				continue_dialogue()
	
	if isRunning:
		coolDown = 0
	else:
		coolDown += 1
	
	timer += 1
	if timer % 2 == 0 and !finished:
		if text.length() == 0:
			text += " " #in case you make it empty so it dont crash
		%textBox.text += text[char]
		char += 1
		if char == text.length():
			finished = true
	if finished and Input.is_action_just_pressed("confirm"):
		if $textBoxControl.visible and isRunning:
			textBoxIndex += 1
			continue_dialogue()
	#Skip text button
	if !finished and Input.is_action_just_pressed("confirm") and char > 3:
		%textBox.text = text
		finished = true
	#Instant text boxes
	if !finished and currentDialogue.messages[textBoxIndex].instant:
		%textBox.text = text
		finished = true
	

func start_dialogue_sequence(dialogue: Dialogue):
	$textBoxControl.visible = true
	isRunning = true
	currentDialogue = dialogue
	textBoxIndex = 0
	if currentDialogue.pauseGame:
		get_tree().get_first_node_in_group("player").process_mode = Node.PROCESS_MODE_DISABLED
	continue_dialogue()
	

func continue_dialogue():
	if !currentDialogue:
		printerr("The dialogue export var is empty!!")
		return
	if !currentDialogue.messages:
		printerr("The dialogue doesn't have any messages!!")
		return
	if textBoxIndex == currentDialogue.messages.size():
		print("reached the end of the dialogue")
		end_textbox()
		return
	if !currentDialogue.messages[textBoxIndex]:
		printerr("Textbox at index ", textBoxIndex, " doesn't exist!!")
		return
	var code = currentDialogue.messages[textBoxIndex].code
	if code != "":
		var script = GDScript.new()
		script.set_source_code("func eval():" + code)
		script.reload()
		var ref = RefCounted.new()
		ref.set_script(script)
		ref.eval()
	
	%nameBox.text = currentDialogue.messages[textBoxIndex].name
	%nameBox.visible = true
	if %nameBox.text == "":
		%nameBox.visible = false
	set_text(currentDialogue.messages[textBoxIndex].text)
	
	if currentDialogue.messages[textBoxIndex].position == "top":
		%textBoxMargin.position.y = -820
		%nameBox.position.y = 240
	else:
		%textBoxMargin.position.y = 0
		%nameBox.position.y = -45
	

func set_text(newText: String):
	text = newText
	finished = false
	char = 0
	%textBox.text = ""

func end_textbox():
	if currentDialogue.keepOnScreenAfterEnd:
		isRunning = false 
	else:
		$textBoxControl.visible = false
	textBoxIndex = 0
	get_tree().get_first_node_in_group("player").process_mode = Node.PROCESS_MODE_INHERIT


func set_position(newPos : Vector2):
	%textBoxMargin.position = newPos
