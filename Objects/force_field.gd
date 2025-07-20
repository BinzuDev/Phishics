extends Area3D



func _process(_delta):
	if has_overlapping_bodies():
		var fish = get_overlapping_bodies()[0]
		if fish.global_position.z > global_position.z:
			fish.linear_velocity.z = min(fish.linear_velocity.z - 0.1, 0)
	
