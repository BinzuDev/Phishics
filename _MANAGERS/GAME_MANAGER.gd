extends Node

var gamePaused : bool
var gameTimer : int = 0
var framefwrd

var freezeframe : int = 0 
var objFreeze #freeze something else when hitstopping
var hideUI : bool = false
var nextScene


enum gameState { #Testing something, not used yet
	MENU,
	GAMEPLAY,
	RESULTSCREEN,
}


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
	get_tree().paused = !get_tree().paused
	gamePaused = get_tree().paused

func reset_level():
	get_tree().reload_current_scene()
	MusicManager.stop_music()
	ScoreManager.reset_everything()

func change_scene(scene : String):
	nextScene = scene
	MenuManager.start_transition()

func level_transition():
	MusicManager.stop_music()
	ScoreManager.reset_everything()
	ScoreManager.show()
	DialogueManager.reset()
	MenuManager.end_transition()
	get_tree().change_scene_to_file.call_deferred(nextScene)



func _physics_process(_delta):
	process_mode = Node.PROCESS_MODE_ALWAYS
	gameTimer += 1
	if Input.is_action_just_pressed("pause"):
		toggle_pause()
	
	if Input.is_action_just_pressed("frameFRWD") and get_tree().paused:
		get_tree().paused = !get_tree().paused
		framefwrd = gameTimer + 1
	
	if gameTimer == framefwrd:
		get_tree().paused = !get_tree().paused
	
	if Input.is_action_just_pressed("reset"):
		reset_level()
		ScoreManager.show()
	
	if Input.is_action_just_pressed("F11"): #fullscreen toggle
		if DisplayServer.window_get_mode() == 4:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			get_window().size = Vector2(1152, 648)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	if freezeframe > 0:
		freezeframe -= 1
		if freezeframe == 0:
			var fish = get_tree().get_first_node_in_group("player")
			fish.process_mode = Node.PROCESS_MODE_INHERIT
			if objFreeze:
				objFreeze.process_mode = Node.PROCESS_MODE_INHERIT
			#get_tree().paused = false
	
	
	
