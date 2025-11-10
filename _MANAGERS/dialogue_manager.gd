extends Node

var text := ""
var timer := 0
var chara := 0
var finished := true
var textBoxIndex := 0
var currentDialogue: Dialogue
var currentDialogueArea: Area3D ##The dialogue_area node
var isRunning := false
var coolDown := 0
var currentDialogueOwner ##The parent node of the dialogue_area object 

var jfgPosition : Vector2

func _ready():
	%textBoxControl.visible = false
	$enterTip.visible = false
	$CanvasLayer/JFG.position = Vector2(1920,1080)
	jfgPosition = Vector2(1920,1080)

func show_prompt(state:bool = true):
	$enterTip.visible = state


func _process(_delta):
	if !%textBoxControl.visible: #this is at the start so it waits an extra frame so you cant
		isRunning = false        #start a dialogue with the same input used to end another one
	
	
	
	#fixes a dumbass glitch where jfg would show up for one frame only when RELOADING tutorial
	$CanvasLayer/JFG.position = jfgPosition
	
	$SubViewport.size = DisplayServer.window_get_size() #jfg
	
	#put the Z icon at the end of the text
	var finalChar = %textBox.get_character_bounds(%textBox.text.length())
	%confirm.position = Vector2(finalChar.position.x+45, finalChar.position.y+30) 
	if !finished:
		%confirm.modulate.a = 0
	else:
		#%confirm.modulate.a = clamp(%confirm.modulate.a+0.1,0,1) #add 10 frames of delay
		%confirm.modulate.a = move_toward(%confirm.modulate.a, 1, 0.033)
	
	
	
	$enterTip/Control.visible = !isRunning #dont show prompt if textbox active
	%confirm.visible = finished and isRunning and %confirm.modulate.a == 1
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
		#%textBox.text += text[chara]
		%textBox.visible_characters += 1
		chara += 1
		if chara == text.length():
			finished = true
	if finished and Input.is_action_just_pressed("confirm"):
		if %textBoxControl.visible and isRunning:
			textBoxIndex += 1
			%confirm.visible = false
			continue_dialogue()
	#Skip text button
	if !finished and Input.is_action_just_pressed("confirm") and chara > 3:
		#%textBox.text = text
		%textBox.visible_characters = text.length()
		chara = text.length()
		finished = true
	#Instant text boxes
	if !finished and currentDialogue.messages[textBoxIndex].instant:
		#%textBox.text = text
		%textBox.visible_characters = text.length()
		chara = text.length()
		finished = true
	

func start_dialogue_sequence(dialogue: Dialogue):
	%textBoxControl.visible = true
	isRunning = true
	currentDialogue = dialogue
	
	textBoxIndex = 0
	print("PAUSE STYLE SYSTEM IS")
	print(currentDialogue.pauseStyleSystem)
	if currentDialogue.pauseStyleSystem:
		ScoreManager.hide()
	if currentDialogue.pauseGame:
		get_tree().get_first_node_in_group("player").process_mode = Node.PROCESS_MODE_DISABLED
	continue_dialogue()
	

func continue_dialogue():
	if !currentDialogue:
		printerr("The dialogue export var is empty!!"); return
	if !currentDialogue.messages:
		printerr("The dialogue doesn't have any messages!!"); return
	if textBoxIndex == currentDialogue.messages.size():
		print("reached the end of the dialogue")
		end_textbox(); return
	if !currentDialogue.messages[textBoxIndex]:
		printerr("Textbox at index ", textBoxIndex, " doesn't exist!!"); return
	var code = currentDialogue.messages[textBoxIndex].code
	if code != "":
		run_code(code)
	var jfg = currentDialogue.messages[textBoxIndex].JFG_animation
	if jfg != "":
		$SubViewport/jelly_fish_girl_IK.play_animation(jfg)
	
	if currentDialogue.speechSFX: #play sound effect if there is one
		currentDialogueArea.get_node(currentDialogue.speechSFX).play()
	
	%nameBox.text = currentDialogue.messages[textBoxIndex].name
	%nameBox.visible = true
	if %nameBox.text == "":
		%nameBox.visible = false
	set_text(currentDialogue.messages[textBoxIndex].text)
	
	if currentDialogue.messages[textBoxIndex].position == "top":
		#%textBoxControl.anchor_top = 0
		#%textBoxControl.anchor_bottom = 0
		#%textBoxControl.offset_left = -420
		#%textBoxControl.offset_bottom = 290
		%nameBox.position.y = 240
	else:
		print("botom")
		#%textBoxControl.anchor_top = 1
		#%textBoxControl.anchor_bottom = 1
		#%textBoxControl.offset_left = 0
		#%textBoxControl.offset_bottom = 0
		%nameBox.position.y = -45
	

func set_text(newText: String):
	newText = newText.replace("? ", "? ​​​​​​​​​​​​​​​​​​​​") ##Waits 40 frames after a "? " (Adds 20 Zero width spaces)
	newText = newText.replace("! ", "! ​​​​​​​​​​​​​​​​​​​​") ##Waits 40 frames after a "! " (Adds 20 Zero width spaces)
	newText = newText.replace("...", "​​​​​.​​​​​.​​​​​.​​​​​") ##wait 10 frames "." wait 10 frames "."  wait 10 frames "."  wait 10 frames 
	newText = newText.replace(". ", ". ​​​​​​​​​​​​​​​​​​​​") ##Waits 40 frames after a ". " (Adds 20 Zero width spaces) 
	newText = newText.replace(",", ",​​​​​​​​​​") ##Waits 20 frames after a "," (Adds 10 Zero width spaces)
	newText = newText.replace("/w", "​​​​​​​​​​") ##replaces "/w" with a 20 frame wait (Adds 10 Zero width spaces)
	
	text = newText
	finished = false
	chara = 0
	#%textBox.text = ""
	%textBox.text = text
	%textBox.visible_characters = 0

func end_textbox():
	if currentDialogue.keepOnScreenAfterEnd:
		isRunning = false 
	else:
		%textBoxControl.visible = false
	textBoxIndex = 0
	get_tree().get_first_node_in_group("player").process_mode = Node.PROCESS_MODE_INHERIT
	get_tree().get_first_node_in_group("player").forceMakeCameraCurrent()
	if currentDialogue.pauseStyleSystem:
		ScoreManager.show()
	if currentDialogue.codePostDialogue != "":
		run_code(currentDialogue.codePostDialogue)


func reset():
	text = ""
	timer = 0
	chara = 0
	finished = true
	textBoxIndex = 0
	currentDialogue = null
	isRunning = false
	coolDown = 0
	%textBoxControl.visible = false
	$enterTip.visible = false
	$CanvasLayer/JFG.position = Vector2(1920,1080)
	show_jfg(false)
	


func run_code(newCode:String):
	var script = GDScript.new()
	script.set_source_code("func eval():" + newCode)
	script.reload()
	var ref = RefCounted.new()
	ref.set_script(script)
	ref.eval()



func set_position(newPos : Vector2):
	%textBoxMargin.position = newPos

##HACK I cant just simply use .visible because of some weird frame buffer bullshit I dont understand
func show_jfg(value:bool = true):
	if value == true:
		jfgPosition = Vector2(0,0)
	else:
		jfgPosition = Vector2(1920,1080)
		$CanvasLayer/JFG.position = Vector2(1920,1080)
	
