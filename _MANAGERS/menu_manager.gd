extends Node

var transitionStart : int = 0
var transitionEnd : int = 0
var focus

func _ready():
	print("menu manager ready")
	%TrickList.visible = false
	$splashScreen.visible = true
	$transitionScreen.visible = true
	$transitionScreen.position = Vector2(-99999, 0)
	toggleMenu()


func _process(_delta):
	#splash screen fadeout
	if Engine.get_frames_drawn() >= 5: #skip the first couple of frames for lag
		$splashScreen.modulate.a -= 0.05
	
	$tips.visible = (GameManager.gamePaused or GameManager.isOnTitleScreen) and !isSubmenuOpen()
	
	
	#backup in case no option is selected
	if Input.is_action_just_pressed("forward") or Input.is_action_just_pressed("back"):
		if get_viewport().gui_get_focus_owner() == null and GameManager.gamePaused:
			%Continue.grab_focus()
	
	
	## Screen transition
	transitionStart = -($transitionScreen.size.x + %fishHead.size.x*0.5) - 100
	transitionEnd = $transitionScreen.size.x + %fishTail.size.x + 100
	#print("screen: ", $transitionScreen.size.x, " tail: ", %fishTail.size.x, " head: ", %fishHead.size.x*0.5)
	#print("S: ", transitionStart, " C: ", $transitionScreen.position.x, " E: ", transitionEnd)
	
	
	## Trick list tab 
	if !%trickTabs.get_tab_bar().has_focus() and %TrickList.visible:
		if Input.is_action_just_pressed("ui_left"):
			switch_tab(false)
		if Input.is_action_just_pressed("ui_right"):
			switch_tab(true)
			
	

func switch_tab(rightSide : bool = true):
	%arrowAnim.stop()
	if rightSide:
		%trickTabs.current_tab = wrapi(%trickTabs.current_tab+1, 0, 4)
		%arrowAnim.play("right_arrow")
	else:
		%trickTabs.current_tab = wrap(%trickTabs.current_tab-1, 0, 4)
		%arrowAnim.play("left_arrow")
	%trickTabs.get_current_tab_control().get_child(0).get_child(0).get_child(0).grab_focus()
	%trickTabs.get_current_tab_control().scroll_vertical = 0


func toggleMenu():
	$PauseMenu.visible = GameManager.gamePaused
	%TrickList.visible = false
	%Tricks.forceReset()
	GameManager.previousUIselection = []
	if GameManager.gamePaused:
		%Continue.grab_focus()
		%PauseList.visible = true
		



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
	

func isSubmenuOpen():
	return %TrickList.visible


#Pause menu options
func _on_continue_pressed():
	GameManager.toggle_pause()

func _on_restart_pressed():
	GameManager.reset_level()

func _on_tricks_pressed():
	GameManager.rememberUichoice()
	%PauseList.visible = false
	%TrickList.visible = true
	GameManager.disableMenuControl = false
	%trickTabs.current_tab = 0
	%movement.grab_focus()
	$TrickList/Panel/trickTabs/Mechanics.scroll_vertical = 0
	

func close_tricks():
	GameManager.disableMenuControl = false
	if GameManager.gamePaused:
		%PauseList.visible = true
	GameManager.focusPreviousUI()
	%TrickList.visible = false
	


func _on_exit_pressed(): 
	GameManager.change_scene("res://Levels/Title_Screen.tscn")


func set_help_tip(newText: String):
	%HelpTip.text = newText

#Debug settings
func hide_menu_in_FBF(): #so the frame by frame button is actually useful
	$PauseMenu.visible = false
	%TrickList.visible = false
	$tips.visible = false

func _on_fish_debug_toggled(toggled_on):
	get_tree().get_first_node_in_group("player").find_child("debugLabel").visible = toggled_on

func fish_debug_on():
	return $PauseMenu/DebugList/HBoxContainer/fish.button_pressed

func _on_surf_debug_toggled(toggled_on):
	get_tree().get_first_node_in_group("player").find_child("debugLabel2").visible = toggled_on

func surf_debug_on():
	return $PauseMenu/DebugList/HBoxContainer/surf.button_pressed

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


func _on_noclip_toggled(_toggled_on = true):
	var value = $PauseMenu/DebugList/HBoxContainer/noclip.button_pressed
	var Player = get_tree().get_first_node_in_group("player")
	Player.noclip = value
	Player.set_collision_mask_value(1, !value)
	Player.set_collision_mask_value(3, !value)


func _on_mute_music_toggled(toggled_on):
	AudioServer.set_bus_mute(4, toggled_on) 
	


func _on_fps_toggled(toggled_on):
	$FPSanchor.visible = toggled_on
