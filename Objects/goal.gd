extends Area3D

@export_file("*.tscn") var nextLevel = "res://Levels/World.tscn"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func _on_body_entered(body: Node3D) -> void:
	if body is player:
		print("GOAL!")
		get_tree().change_scene_to_file.call_deferred(nextLevel)
