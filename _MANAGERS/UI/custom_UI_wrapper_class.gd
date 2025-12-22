class_name CustomUIWidget extends Control

## -------------------------------------------------------------------
## This class takes care of common functions for buttons/toggles/sliders
##

@export_multiline var helpText : String = ""

var mouseHovered : bool = false

func _ready():
	focus_entered.connect(_on_focus_entered)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_focus_entered():
	MenuManager.set_help_tip(helpText)

func _on_mouse_entered():
	mouseHovered = true
	grab_focus()

func _on_mouse_exited():
	mouseHovered = false
