extends Node3D

var logoTimer := 0

func _ready():
	ScoreManager.hide()
	%tutorial.grab_focus()

func _process(_delta):
	logoTimer += 1
	$logo.rotation_degrees.z = sin(logoTimer*0.02) * 3


func _on_tutorial_button_pressed():
	GameManager.change_scene("res://Levels/tutorial.tscn")

func _on_play_button_pressed():
	GameManager.change_scene("res://Levels/World.tscn")


func _on_exit_button_pressed():
	get_tree().quit()
