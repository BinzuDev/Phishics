extends Node3D




func _ready():
	pass

func _process(delta: float) -> void:
	#makes him talk
	if $dialogueArea.has_overlapping_bodies() and Input.is_action_just_pressed("confirm"):
		print("pith")
		$AudioStreamPlayer3D.play()
