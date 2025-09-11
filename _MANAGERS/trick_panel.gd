@tool
extends Panel

@export var trickName : String = ""
@export var score : String = ""
@export_enum("Common", "Uncommon", "Rare", "Legendary", "Mechanic", "Surf Combo Input") var rarity : String = "Common"
@export_multiline var description : String = ""
@export_multiline var description2 : String = ""

@onready var stylebox: StyleBoxFlat = get_theme_stylebox("panel").duplicate()



func set_text():
	%name.text = trickName
	%score.text = "Value: " + score
	%rarity.text = rarity
	%description.text = description
	%description2.text = "  " + description2
	if description2 != "":
		%description.text += "\n"
	if rarity == "Mechanic" or rarity == "Surf Combo Input":
		%score.text = ""

func _ready():
	set_text()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

func _process(_delta):
	if Engine.is_editor_hint():
		set_text()


func _on_mouse_entered():
	grab_focus()

func _on_mouse_exited():
	release_focus()
	
func set_border_width(value: float):
	stylebox.border_width_left = value
	stylebox.border_width_top = value
	stylebox.border_width_right = value
	stylebox.border_width_bottom = value
	add_theme_stylebox_override("panel", stylebox)
	
func _on_focus_entered():
	print(name, " focus entered")
	var tween = create_tween()
	tween.tween_method(set_border_width, 0, 6, 0.3) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_OUT)

func _on_focus_exited():
	print(name, " focus exited")
	var tween = create_tween()
	tween.tween_method(set_border_width, 6, 0, 0.3) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_OUT)
