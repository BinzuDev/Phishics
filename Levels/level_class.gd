extends Node3D
class_name Level


func _ready():
	print("level is fully loaded")
	GameManager.isOnTitleScreen = false
	#dont do the transition when the game opens
	if GameManager.gameTimer > 15:
		var waitTime = 0.2
		if get_tree().current_scene.name == "World":
			waitTime = 0.5 #wait a little longer on the level bcs its so big
		await get_tree().create_timer(waitTime).timeout
		print(waitTime, "s long loading")
		MenuManager.end_transition()
	
