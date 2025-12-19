extends MeshInstance3D


func _on_glitch_body_entered(body):
	if body is Player:
		ScoreManager.give_points(1000, 10, true, "\"ITS NOT A BUG, ITS A FEATURE!\"")
		ScoreManager.play_trick_sfx("legendary")
