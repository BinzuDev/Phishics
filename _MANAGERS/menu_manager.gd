extends Node

var transitionStart : int = 0
var transitionEnd : int = 0

func _ready():
	print("menu manager ready")
	$PauseMenu/TrickList.visible = false
	$splashScreen.visible = true
	$transitionScreen.visible = true
	$transitionScreen.position = Vector2(-99999, 0)
	toggleMenu()


func _process(_delta):
	#splash screen fadeout
	if Engine.get_frames_drawn() >= 5: #skip the first couple of frames for lag
		$splashScreen.modulate.a -= 0.05
	
	transitionStart = -($transitionScreen.size.x + %fishHead.size.x*0.5) - 100
	transitionEnd = $transitionScreen.size.x + %fishTail.size.x + 100
	#print("screen: ", $transitionScreen.size.x, " tail: ", %fishTail.size.x, " head: ", %fishHead.size.x*0.5)
	#print("S: ", transitionStart, " C: ", $transitionScreen.position.x, " E: ", transitionEnd)
	


func toggleMenu():
	$PauseMenu.visible = GameManager.gamePaused
	if GameManager.gamePaused:
		%Continue.grab_focus()
		%PauseList.visible = true
		%TrickList.visible = false
		



func setTransition(value: float):
	$transitionScreen.position.x = value


func start_transition():
	$transitionScreen.visible = true
	var tween = create_tween()
	tween.finished.connect(_fade_in_over)
	tween.tween_method(setTransition, transitionStart, 0, 0.6) \
		.set_trans(Tween.TRANS_LINEAR) \
		.set_ease(Tween.EASE_OUT)
	
func _fade_in_over():
	await get_tree().create_timer(0.03).timeout
	GameManager.level_transition()


func end_transition():
	var tween = create_tween()
	tween.finished.connect(_fade_out_over)
	tween.tween_method(setTransition, 0, transitionEnd, 0.6) \
		.set_trans(Tween.TRANS_LINEAR) \
		.set_ease(Tween.EASE_OUT)
	
func _fade_out_over():
	GameManager.disableMenuControl = false
	$transitionScreen.visible = false


func resetFocus():
	%Continue.forceReset()
	%Restart.forceReset()
	%Tricks.forceReset()
	%Exit.forceReset()
	


#Pause menu options
func _on_continue_pressed():
	GameManager.toggle_pause()

func _on_restart_pressed():
	GameManager.reset_level()

func _on_tricks_pressed():
	%PauseList.visible = false
	%TrickList.visible = true
	GameManager.disableMenuControl = false
	%movement.grab_focus()
	$PauseMenu/TrickList/Panel/ScrollContainer.scroll_vertical = -500
	

func _on_exit_pressed(): 
	GameManager.change_scene("res://Levels/Title_Screen.tscn")


func set_help_tip(newText: String):
	%HelpTip.text = newText

#Debug settings
func hide_menu_in_FBF(): #so the frame by frame button is actually useful
	$PauseMenu.visible = false
	#%PauseList.visible = false
	

func _on_fish_debug_toggled(toggled_on):
	get_tree().get_first_node_in_group("player").find_child("debugLabel").visible = toggled_on

func _on_surf_debug_toggled(toggled_on):
	get_tree().get_first_node_in_group("player").find_child("debugLabel2").visible = toggled_on

func _on_music_debug_toggled(toggled_on):
	MusicManager.find_child("musicDebug").visible = toggled_on

func _on_style_debug_toggled(toggled_on):
	ScoreManager.find_child("debugLabel").visible = toggled_on

func _on_fresh_debug_toggled(toggled_on):
	ScoreManager.find_child("freshDebugLabel").visible = toggled_on


func _on_hide_ui_toggled(toggled_on):
	%PauseList.visible = false
	GameManager.hideUI = toggled_on
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
	
