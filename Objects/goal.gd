extends Area3D

@export_file("*.tscn") var nextLevel = "res://Levels/World.tscn"


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
	

func _on_body_entered(body: Node3D) -> void:
	if body is player:
		GameManager.change_scene(nextLevel)
		
