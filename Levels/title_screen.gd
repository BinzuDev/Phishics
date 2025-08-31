extends Node3D

var logoTimer := 0

func _ready():
	ScoreManager.hide()
	%tutorial.grab_focus()
	$UI/Credits.visible = false

func _process(_delta):
	logoTimer += 1
	$logo.rotation_degrees.z = sin(logoTimer*0.02) * 3
	#backup in case no option is selected
	if Input.is_action_just_pressed("forward") or Input.is_action_just_pressed("back"):
		if get_viewport().gui_get_focus_owner() == null:
			%tutorial.grab_focus()
	
	


func _on_tutorial_button_pressed():
	GameManager.change_scene("res://Levels/tutorial.tscn")

func _on_play_button_pressed():
	GameManager.change_scene("res://Levels/World.tscn")


func _on_credits_button_pressed():
	$UI/MenuOptions.visible = false
	$UI/Credits.visible = true
	%creditsReturn.grab_focus()
	

func _on_exit_button_pressed():
	get_tree().quit()


func _on_credits_go_back_pressed():
	$UI/MenuOptions.visible = true
	$UI/Credits.visible = false
	%credits.grab_focus()
	


func _on_tutorial_hovered():
	$JFG.play_animation("Stretching")
	%HelpTip.text = "Learn the basics of how to play."

func _on_play_hovered():
	$JFG.play_animation("Jumping")
	%HelpTip.text = "Start a game of Phishics!"

func _on_tricks_hovered():
	$JFG.play_animation("Cutesy")
	%HelpTip.text = "Discover all the techniques you can pull off!"

func _on_credits_hovered():
	$JFG.play_animation("Blahaj")
	%HelpTip.text = "Learn about the creators of Phishics."

func _on_exit_hovered():
	$JFG.play_animation("Sad")
	%HelpTip.text = "Close the game."


func _on_exit_just_pressed():
	$JFG.play_animation("Stare")
