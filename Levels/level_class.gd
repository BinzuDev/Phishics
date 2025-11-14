extends Node3D
class_name Level

@export var song : String = "OST1"


func _ready():
	print("level is fully loaded")
	GameManager.isOnTitleScreen = false
	#dont do the transition when the game opens
	if GameManager.gameTimer > 15:
		var waitTime = 0.6
		await get_tree().create_timer(waitTime).timeout
		print(waitTime, "s long loading")
		MenuManager.end_transition()
	MusicManager.change_music(song)
	
	
