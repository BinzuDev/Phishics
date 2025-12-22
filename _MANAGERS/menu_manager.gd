extends Node

#fish transition screen
var transitionStart : int = 0
var transitionEnd : int = 0

#0: outside tutorial | 1: waiting for player to open trick list | 2: player has opened the tricklist
var tutorialTrickList : int = 0

var stack : Array = []


func _ready():
	print("menu manager ready")
	%TrickList.visible = false
	$splashScreen.visible = true
	$transitionScreen.position = Vector2(-99999, 0)
	%HelpTip.visible = true
	toggleMenu()
	$pauseBG/AnimationPlayer.play("RESET")
	#without this, the first transition screen will lag and teleport because it needs to load
	$transitionScreen.visible = true
	await get_tree().create_timer(0.5).timeout
	$transitionScreen.visible = false


func get_UI_size():
	return $screenSizeDetect.global_position



func _physics_process(delta):
	#splash screen fadeout
	if Engine.get_frames_drawn() >= 5: #skip the first couple of frames for lag
		$splashScreen.modulate.a -= 0.05
	
	#animates the surfJump icon in the trick list
	%surfJumpMeter.value = wrap(%surfJumpMeter.value+1, -10, 30) 



func _process(delta):
	
	%HelpTip.visible = (GameManager.gamePaused or GameManager.isOnTitleScreen) and !GameManager.frameByFrameMode
	if %TrickList.visible:
		%HelpTip.visible = false
	
	%HelpTip.label_settings.font_size = 40
	%HelpTip.label_settings.outline_size = 20
	#make the helptip smaller in the settings cause they're generally longer
	if SettingsManager.menu_is_visible(): 
		%HelpTip.label_settings.font_size = 30
		%HelpTip.label_settings.outline_size = 15
	
	
	##Force press continue
	if Input.is_action_just_pressed("cancel") or Input.is_action_just_pressed("pause"):
		if GameManager.gamePaused == true and %PauseList.visible and !GameManager.frameByFrameMode:
			if !GameManager.disableMenuControl and !GameManager.disableUnpause:
				printerr("force press continue")
				%Continue.grab_focus()
				%Continue._on_button_pressed()
				_on_continue_just_pressed()
	
	
	#backup in case no option is selected
	#if Input.is_action_just_pressed("forward") or Input.is_action_just_pressed("back"):
	#	if get_viewport().gui_get_focus_owner() == null and GameManager.gamePaused:
	#		%Continue.grab_focus()
	
		## Trick list tab 
	if !%trickTabs.get_tab_bar().has_focus() and %TrickList.visible:
		if Input.is_action_just_pressed("ui_left"):
			switch_tab(false)
		if Input.is_action_just_pressed("ui_right"):
			switch_tab(true)
	
	## Screen transition
	transitionStart = -($transitionScreen.size.x + %fishHead.size.x*0.5) - 100
	transitionEnd = $transitionScreen.size.x + %fishTail.size.x + 100
	#print("screen: ", $transitionScreen.size.x, " tail: ", %fishTail.size.x, " head: ", %fishHead.size.x*0.5)
	#print("S: ", transitionStart, " C: ", $transitionScreen.position.x, " E: ", transitionEnd)
	
	
	
	
	## Loading icon
	#Its in process so that you can see the icon slow down during lag
	if $transitionScreen.visible:
		var fps = 1 / delta
		var interval = int( (fps+19) / 20 )
		if GameManager.every_x_frames(interval):
			%LoadingIcon.frame = wrap(%LoadingIcon.frame+1, 0, 12)
		#print("fps is ", fps, " divided by 20 is ", int((fps+19) / 20))
		
	






func switch_tab(rightSide : bool = true):
	%arrowAnim.stop()
	if rightSide:
		%trickTabs.current_tab = clamp(%trickTabs.current_tab+1, 0, 3)
		%arrowAnim.play("right_arrow")
	else:
		if %trickTabs.current_tab == 0:
			printerr("no")
			%trickGoBack.grab_focus()
			return
		%trickTabs.current_tab = clamp(%trickTabs.current_tab-1, 0, 3)
		%arrowAnim.play("left_arrow")
	if !%trickGoBack.has_focus():
		%trickTabs.get_current_tab_control().get_child(0).get_child(0).get_child(0).grab_focus()
	%trickTabs.get_current_tab_control().scroll_vertical = 0
	


func toggleMenu():
	$pauseBG/AnimationPlayer.play("RESET")
	if GameManager.gamePaused: ##Take a screenshot of the game and use it as a background
		var screenshot = get_viewport().get_texture().get_image()
		$pauseBG.texture = ImageTexture.create_from_image(screenshot)
		$pauseBG/AnimationPlayer.play("start_water_effect")
	$pauseBG.visible = GameManager.gamePaused
	var fish = get_tree().get_first_node_in_group("player")
	if fish:
		fish.should_camera_render(!$pauseBG.visible)
	$PauseMenu.visible = GameManager.gamePaused
	%TrickList.visible = false
	%Tricks.forceReset()
	GameManager.previousUIselection = []
	print("toggleMenu")
	MusicManager.shouldMusicMuffle = GameManager.gamePaused
	
	if GameManager.gamePaused:
		ScoreManager.show_counter(true)
		%Continue.grab_focus()
		%PauseList.visible = true
		GameManager.disableUnpause = true
		

##So that you can't unpause the game during the pausing animation
func _on_water_animation_finished(anim_name):
	GameManager.disableUnpause = false


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
	return %TrickList.visible or SettingsManager.menu_is_visible()


	## Pause menu options ##
func _on_continue_just_pressed():
	get_tree().get_first_node_in_group("player").should_camera_render(true)
	$pauseBG/AnimationPlayer.play("end_water_effect")
	MusicManager.shouldMusicMuffle = false
func _on_continue_pressed():
	GameManager.toggle_pause()

func _on_restart_pressed():
	GameManager.reset_level()

func _on_tricks_pressed():
	GameManager.rememberUichoice()
	%PauseList.visible = false
	%TrickList.visible = true
	%HelpTip.visible = false
	GameManager.disableMenuControl = false
	%trickTabs.current_tab = 0
	%trickGoBack.forceReset()
	%movement.grab_focus()
	$TrickList/Panel/trickTabs/Mechanics.scroll_vertical = 0
	if tutorialTrickList == 1: #forces you to open tricks in tutorial
		tutorialTrickList = 2
	

func close_tricks():
	GameManager.disableMenuControl = false
	if GameManager.gamePaused:
		%PauseList.visible = true
	GameManager.focusPreviousUI()
	%TrickList.visible = false
	

func _on_settings_pressed():
	GameManager.rememberUichoice()
	GameManager.disableMenuControl = false
	%PauseList.visible = false
	SettingsManager.show_settings_menu()
	%Options.forceReset()
	


func _on_exit_pressed(): 
	GameManager.change_scene("res://Levels/Title_Screen.tscn")


func set_help_tip(newText: String):
	%HelpTip.text = newText




	## Debug settings ##
#region Debug settings
func hide_menu_in_FBF(): #so the frame by frame button is actually useful
	$PauseMenu.visible = false
	%TrickList.visible = false
	%HelpTip.visible = false
	$pauseBG.visible = false
	get_tree().get_first_node_in_group("player").should_camera_render(true)

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
	#%PauseList.visible = false
	GameManager.hideUI = toggled_on
	if toggled_on:
		ScoreManager.hide()
	else:
		ScoreManager.show()

func _on_noclip_toggled(_toggled_on = true):
	var value = $PauseMenu/DebugList/HBoxContainer/noclip.button_pressed
	var fish = get_tree().get_first_node_in_group("player")
	fish.noclip = value
	fish.set_collision_mask_value(1, !value)
	fish.set_collision_mask_value(3, !value)
	

func _on_fps_toggled(toggled_on):
	$FPSanchor.visible = toggled_on

func _on_mobile_toggled(toggled_on):
	if toggled_on:
		#DisplayServer.window_set_size(Vector2(1080, 1312), 0)
		DisplayServer.window_set_size(Vector2(1080, 1920), 0)
		SettingsManager.find_child("UIscale").max_value = 1.7
	else:
		DisplayServer.window_set_size(Vector2(1152, 648), 0)

#endregion
