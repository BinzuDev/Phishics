extends Area3D


var cooldown := 0
var speed : float = 1.0
var freshCooldown := 0

func _process(_delta: float) -> void:
	%mesh.rotation_degrees.x += speed
	cooldown += 1
	freshCooldown = max(freshCooldown-1, 0)
	speed = max(speed - 0.2, 1.0)


func _on_body_entered(body: Node3D) -> void:
	if body is player and cooldown > 20:
		ScoreManager.give_points(500, 2, true, "RING", "rare")
		if freshCooldown == 0:
			ScoreManager.update_freshness(self)
			freshCooldown = 60 #because its unfair to ruin your freshness because you go in and out
		ScoreManager.play_trick_sfx("rare")
		cooldown = 0
		speed = 15
		body.angular_velocity *= 1.2
