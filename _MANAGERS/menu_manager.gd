extends Node


func _ready():
	print("menu manager ready")
	

func _process(_delta):
	$PauseMenu.visible = GameManager.gamePaused
	if Input.is_action_just_pressed("frameFRWD"):
		%hideUI.button_pressed = true
	$PauseMenu/CenterMargin.visible = !%hideUI.button_pressed
	

#Pause menu options
func _on_continue_pressed():
	GameManager.toggle_pause()

func _on_restart_pressed():
	GameManager.toggle_pause()
	GameManager.reset_level()



#Debug settings
func _on_fish_debug_toggled(toggled_on):
	get_tree().get_first_node_in_group("player").find_child("debugLabel").visible = toggled_on
	

func _on_music_debug_toggled(toggled_on):
	MusicManager.find_child("musicDebug").visible = toggled_on

func _on_style_debug_toggled(toggled_on):
	ScoreManager.find_child("debugLabel").visible = toggled_on

func _on_fresh_debug_toggled(toggled_on):
	ScoreManager.find_child("freshDebugLabel").visible = toggled_on


func _on_hide_ui_toggled(toggled_on):
	if toggled_on:
		ScoreManager.hide()
	else:
		ScoreManager.show()


func _on_noclip_toggled(toggled_on):
	var Player = get_tree().get_first_node_in_group("player")
	Player.noclip = toggled_on
	Player.set_collision_mask_value(1, !toggled_on)
	Player.set_collision_mask_value(3, !toggled_on)


func _on_mute_music_toggled(toggled_on):
	AudioServer.set_bus_mute(4, toggled_on) 
	
