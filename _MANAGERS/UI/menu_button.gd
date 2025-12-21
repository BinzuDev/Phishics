class_name UiButton extends Label

#static means that it affects all instances globally
static var ignoreInputs : bool = false #so that during animations you cant press anything
var hovered : bool = false

@export var helpText: String = ""

@onready var stylebox: StyleBoxFlat = $backPanel/blueBorder.get_theme_stylebox("panel").duplicate()

signal on_button_pressed #After you press the button and its done doing the little animation
signal on_button_just_pressed #the EXACT moment you press the button
signal on_button_hovered
signal on_button_exited


func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

func _on_mouse_entered():
	grab_focus()
	hovered = true

func _on_mouse_exited():
	#release_focus()
	hovered = false

func set_border_width(value: float):
	stylebox.border_width_left = value
	$backPanel/blueBorder.add_theme_stylebox_override("panel", stylebox)
	
func _on_focus_entered():
	#print(name, " focus enter")
	if !ignoreInputs and !GameManager.disableMenuControl:
		$selectSFX.play()
		on_button_hovered.emit()
		MenuManager.set_help_tip(helpText)
		var tween = create_tween()
		tween.tween_method(set_border_width, 0, 50, 0.3) \
			.set_trans(Tween.TRANS_EXPO) \
			.set_ease(Tween.EASE_OUT)

func _on_focus_exited():
	#print(name, " focus exited")
	if !ignoreInputs and !GameManager.disableMenuControl:
		on_button_exited.emit()
		var tween = create_tween()
		tween.tween_method(set_border_width, 50, 0, 0.3) \
			.set_trans(Tween.TRANS_EXPO) \
			.set_ease(Tween.EASE_OUT)

func forceReset():
	set_border_width(0)
	ignoreInputs = false


func _on_button_pressed():
	print(name, " pressed")
	if !ignoreInputs and !GameManager.disableMenuControl:
		$confirmSFX.play()
		GameManager.disableMenuControl = true
		var tween = create_tween()
		tween.finished.connect(_on_animation_finished)
		tween.tween_method(set_border_width, 50, 480, 0.3) \
			.set_trans(Tween.TRANS_BACK) \
			.set_ease(Tween.EASE_IN)


func _on_animation_finished(): #when click animation done
	print(name, " animation done")
	$Timer.start() #wait a second so the player can see the animation
func _on_timer_timeout():
	ignoreInputs = false
	on_button_pressed.emit() #you can connect anything you want using this signal


func _process(_delta):
	#things can be buggy if you click during loading, so wait 10 frames
	if has_focus() and !GameManager.game_just_opened():
		if Input.is_action_just_pressed("confirm") and !GameManager.disableMenuControl:
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and !hovered:
				print("CANCEL MENU INPUT")
				return #cancel if you pressed the mouse but the mouse isnt on it
			_on_button_pressed()
			on_button_just_pressed.emit()
			ignoreInputs = true
	
