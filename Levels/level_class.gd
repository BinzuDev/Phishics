@icon("res://icons/level.png")
extends Node3D
class_name Levelq

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
	var wormCount = get_tree().get_node_count_in_group("worms")
	ScoreManager.set_counter_amount(0, wormCount)
	
	
