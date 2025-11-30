@tool
extends Control

signal pressed(toggle:bool)

@export var toggle_name : String = "Toggle"
@export var value : bool = false :
	set(state):
		print("setting state of ", name)
		value = state
		if value == true:
			$AnimationPlayer.play("toggle_on")
		else:
			$AnimationPlayer.play_backwards("toggle_on")

@export_multiline var helpText : String = ""

func _ready():
	pass

func _process(delta):
	%hovered_off.visible = has_focus()
	%hovered_on.visible = has_focus()
	%normal_off.visible = !has_focus()
	%normal_on.visible = !has_focus()
	$Label.text = toggle_name
	
	if has_focus() and Input.is_action_just_pressed("confirm") and !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		value = !value
		if value == true:
			$AnimationPlayer.play("toggle_on")
		else:
			$AnimationPlayer.play_backwards("toggle_on")
		pressed.emit(value)
	


func _on_focus_entered():
	MenuManager.set_help_tip(helpText)
