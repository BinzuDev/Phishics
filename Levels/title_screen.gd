extends Level

var logoTimer := 0
var introFinished : bool = true

func _ready():
	super()
	GameManager.isOnTitleScreen = true
	ScoreManager.hide()
	GameManager.disableMenuControl = false
	%tutorial.grab_focus()
	$UI/Credits.visible = false
	if GameManager.game_just_opened():
		introFinished = false
		$Transitions.play("press_any_key_screen")
	
	


func _input(event):
	if event is InputEventKey:
		if event.pressed and !introFinished:
			$Transitions.play("any_key_pressed")
			$StartSfx.play()
			introFinished = true


func _physics_process(_delta):
	logoTimer += 1
	%PhishicsLogo.rotation_degrees.z = sin(logoTimer*0.01) * 3
	
	$UI.visible = !MenuManager.isSubmenuOpen() ##TODO replace
	
	#backup in case no option is selected
	if Input.is_action_just_pressed("forward") or Input.is_action_just_pressed("back"):
		if get_viewport().gui_get_focus_owner() == null:
			%tutorial.grab_focus()
	


func _on_tutorial_button_pressed():
	GameManager.change_scene("res://Levels/tutorial.tscn")

func _on_play_button_pressed():
	GameManager.change_scene("res://Levels/World.tscn")

func _on_tricks_button_pressed():
	MenuManager._on_tricks_pressed()
	$UI.visible = false


func _on_settings_button_pressed():
	MenuManager._on_settings_pressed()
	$UI.visible = false


func _on_credits_button_pressed():
	$UI/MenuOptions.visible = false
	$UI/Credits.visible = true
	GameManager.disableMenuControl = false
	%creditsReturn.grab_focus()
	

func _on_exit_button_pressed():
	get_tree().quit()


func _on_credits_go_back_pressed():
	$UI/MenuOptions.visible = true
	$UI/Credits.visible = false
	GameManager.disableMenuControl = false
	%credits.grab_focus()
	


func _on_tutorial_hovered():
	$JFG.play_animation("Stretching")

func _on_play_hovered():
	$JFG.play_animation("Jumping")

func _on_tricks_hovered():
	$JFG.play_animation("Cutesy")

func _on_credits_hovered():
	$JFG.play_animation("Blahaj")

func _on_exit_hovered():
	$JFG.play_animation("Sad")

func _on_exit_just_pressed():
	$JFG.play_animation("Stare")
