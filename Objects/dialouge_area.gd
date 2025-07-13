extends Area3D




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if has_overlapping_bodies() and Input.is_action_just_pressed("confirm"):
		#%dialougeColorRect.visable = true
		print("IN CHAT AREA")
		DialogueManager.set_text("hello mario ") 
