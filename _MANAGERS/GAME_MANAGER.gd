extends Node

var gamePaused : bool
var isOnTitleScreen : bool = false
##Stops you from pausing/unpausing during button animations or screen transitions
var disableMenuControl : bool = false 
var disableUnpause : bool = false ##Disable unpausing during the pausing animation
var previousUIselection = [] ##Stores the last buttons you were hovering before you switched menu
var gameTimer : int = 0
var framefwrd
var frameByFrameMode : bool = false

var freezeframe : int = 0 
var objFreeze #freeze something else when hitstopping
var hideUI : bool = false
var nextScene




##Allows you to pause the game for x amount of frames, for impact and juice
func hitstop(frames: int, objToPause: Node3D = null):
	freezeframe = frames
	#get_tree().paused = true
	var fish = get_tree().get_first_node_in_group("player")
	fish.process_mode = Node.PROCESS_MODE_DISABLED
	if objToPause != null:
		objFreeze = objToPause
		objToPause.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	#objToPause.process_mode = Node.PROCESS_MODE_DISABLED
	


func toggle_pause():
	Engine.time_scale = 1 #in case you pause inside a slowmo area
	AudioServer.get_bus_effect(4,0).pitch_scale = 1
	if !isOnTitleScreen:
		disableMenuControl = false
		get_tree().paused = !get_tree().paused
		gamePaused = get_tree().paused
		MenuManager.toggleMenu()
	

func reset_level():
	if !isOnTitleScreen:
		change_scene(get_tree().current_scene.scene_file_path)


func forceUnpause():
	get_tree().paused = false
	gamePaused = get_tree().paused
	MenuManager.toggleMenu()



##This is the function you use to change maps
func change_scene(scene : String):
	disableMenuControl = true
	nextScene = scene
	##It calls this function which starts the transition animation in menu manager
	MenuManager.start_transition()

##Once the transition animation is over, this function gets called and
##resets everything and loads the next map
func level_transition():
	forceUnpause()
	ScoreManager.reset_everything()
	ScoreManager.show()
	DialogueManager.reset()
	MenuManager.resetFocus()
	get_tree().change_scene_to_file.call_deferred(nextScene)
##After the level is loaded, level_class.gd tells menu manager
##to play the 2nd screen transition animation

##Stores what you were hovering on before entering a submenu
func rememberUichoice():
	previousUIselection.append(get_viewport().gui_get_focus_owner())

##Focus on previous selection after closing a submenu
func focusPreviousUI():
	previousUIselection.pop_back().grab_focus()


func _process(_delta):
	#print("menu disabled: ", disableMenuControl, " focus: ", get_viewport().gui_get_focus_owner(), " ", previousUIselection)
	process_mode = Node.PROCESS_MODE_ALWAYS
	gameTimer += 1
	
	if Input.is_action_just_pressed("pause"):
		if (disableMenuControl == false and gamePaused == false) or frameByFrameMode:
			print(disableMenuControl, gamePaused, frameByFrameMode)
			toggle_pause()
	
	if Input.is_action_just_pressed("frameFRWD") and get_tree().paused:
		get_tree().paused = !get_tree().paused
		MenuManager.hide_menu_in_FBF()
		framefwrd = gameTimer + 1
		frameByFrameMode = true
	
	if gameTimer == framefwrd:
		get_tree().paused = !get_tree().paused
	
	if Input.is_action_just_pressed("reset"): #Pressing the R key
		if disableMenuControl == false:
			reset_level()
		
	
	if Input.is_action_just_pressed("quit_game_safely"):
		get_tree().quit() #closes the game unforcefully, unlike F8
	
	
	if Input.is_action_just_pressed("F11"): #fullscreen toggle
		if DisplayServer.window_get_mode() >= 3:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			get_window().size = Vector2(1152, 648)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	

func _physics_process(delta):
	if freezeframe > 0:
		freezeframe -= 1
		if freezeframe == 0:
			var fish = get_tree().get_first_node_in_group("player")
			fish.process_mode = Node.PROCESS_MODE_INHERIT
			if objFreeze:
				objFreeze.process_mode = Node.PROCESS_MODE_INHERIT
			#get_tree().paused = false
	
	

##Used by custom code inside dialogues because get_tree() 
##is a node function and you dont have access to it
func get_current_scene():
	return get_tree().current_scene
func get_fish():
	return get_tree().get_first_node_in_group("player")
