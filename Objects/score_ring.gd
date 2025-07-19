extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	%MeshInstance3D.rotation.x += 0.02

func _on_body_entered(body: Node3D) -> void:
	if body is player:
		ScoreManager.give_points(500, 2, true, "RING")
		ScoreManager.play_trick_sfx("rare")
		
		
