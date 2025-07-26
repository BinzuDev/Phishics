extends Node

var gamePaused : bool
var gameTimer : int = 0
var framefwrd

var freezeframe : int = 0

enum gameState { #Testing something, not used yet
	MENU,
	GAMEPLAY,
	RESULTSCREEN,
}


func toggle_pause():
	get_tree().paused = !get_tree().paused
	gamePaused = get_tree().paused


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
		get_tree().reload_current_scene()
		MusicManager.stop_music()
		ScoreManager.reset_everything()
	
	if Input.is_action_just_pressed("F11"): #fullscreen toggle
		if DisplayServer.window_get_mode() == 4:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			get_window().size = Vector2(1152, 648)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	if freezeframe > 0:
		freezeframe -= 1
		if freezeframe == 0:
			get_tree().paused = false
	
