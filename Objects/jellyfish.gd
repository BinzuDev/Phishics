extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	#hopping on jellyfish
	if body is player and body.diving:
		body.linear_velocity = Vector3.ZERO
		body.apply_central_impulse(Vector3.UP * 50)
