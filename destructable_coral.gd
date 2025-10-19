extends Node3D
var touched = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _coral_spread():
	for child in $corals.get_children():
		if child is RigidBody3D:
			child.collision_mask = child.collision_mask | 1 #enables collison with the world so we can plant it in sand
			child.gravity_scale = 0.01



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is player and not touched:
		_coral_spread()
		touched = true
		
		#trick
		ScoreManager.give_points(200, 1, true, "DESTRUCTION")
		ScoreManager.update_freshness(self)
		ScoreManager.play_trick_sfx("uncommon")
		
		print("touched")
