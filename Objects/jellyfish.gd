extends Node3D

@export var speed = 5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#store y axis
	%AnimationJellyfish.play("Jellyfish")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#makes him move
	%PathFollowJellyfish.progress += speed * _delta
	
	#sin
	#var time = 0
	#var amplitude = 1
	#var frequency = 2
	#time += _delta
	#position.y = sin(time * frequency) * amplitude
	  
	#checks amount reached in path
	if %PathFollowJellyfish.progress_ratio >= 0.3:
		print("Reached over 30% of the path")
	


func _on_body_entered(body: Node3D) -> void:
	#hopping on jellyfish
	if body is player and body.diving:
		body.linear_velocity = Vector3.ZERO
		body.apply_central_impulse(Vector3.UP * 50)
