extends Node3D

var logoTimer := 0

func _ready():
	ScoreManager.hide()
	%tutorial.grab_focus()
	$UI/Credits.visible = false

func _process(_delta):
	logoTimer += 1
	$logo.rotation_degrees.z = sin(logoTimer*0.02) * 3


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
	$JFG.play_animation("T-pose")

func _on_play_hovered():
	$JFG.play_animation("idle")

func _on_tricks_hovered():
	$JFG.play_animation("wave")

func _on_credits_hovered():
	$JFG.play_animation("Hug")

func _on_exit_hovered():
	$JFG.play_animation("Sad")
