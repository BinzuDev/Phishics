@icon("res://Icons/level.png")
class_name Level extends Node3D

@export var song : String = "OST1"

var waitingForLoad : bool = false
var stableFrames := 0
var totalWaitTime := 0
const REQUIRED_STABLE_FRAMES := 10
const STABLE_TRESHHOLD := 0.025 # 25 ms = 40 FPS

func _ready():
	GameManager.isOnTitleScreen = false
	#dont do the transition when the game opens
	if !GameManager.game_just_opened():
		print("level is ready, waiting for lag to end...")
		var waitTime = 0.2
		await get_tree().create_timer(waitTime).timeout
		print(waitTime, "s long loading")
		waitingForLoad = true
	else:
		finish_level_setup()
	


##-- THIS FUNCTION DOES NOT RUN IF THE SCENE HAS A PROCESS FUNCTION OF HIS OWN --##
## Waits until the game stops being laggy before ending the loading screen
func _process(delta):
	
	if waitingForLoad:
		totalWaitTime += 1
		print("loading | delta: ", snapped(delta, 0.001), "s. FPS: ", snapped(1/delta, 0.1), " wait time: ", totalWaitTime)
		if delta < STABLE_TRESHHOLD:
			stableFrames += 1
			print("FRAME IS STABLE! total: ", stableFrames)
			if stableFrames == REQUIRED_STABLE_FRAMES:
				MenuManager.end_transition()
				finish_level_setup()
		if totalWaitTime > 120:
			printerr("game is still laggy after 120 frames, ending the loading screen anyway")
			MenuManager.end_transition()
			finish_level_setup()
			
		


func finish_level_setup():
	waitingForLoad = false
	MusicManager.change_music(song)
	var wormCount = get_tree().get_node_count_in_group("worms")
	ScoreManager.set_counter_amount(0, wormCount)
