@icon("res://icons/jellyfish.png")
extends PathFollow3D


@export var speed = 5
@export var PathFollow: PathFollow3D
@export_range(5, 100, 1.0) var bounceForce : int = 25 ##How high the fish will bounce
##How much the fish's horizontal speed will be affected. 
##0: go straight up.  1: keep your speed. 2: double your speed
@export_range(0, 2, 0.1, "suffix:x") var hSpeedMultiplier : float = 0.5

var TruePos = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#store y axis
	%AnimationJellyfish.play("Jellyfish")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	TruePos = position.y
	#print(TruePos)
	
	
	#makes him move
	progress += speed * _delta
	
	#sin
	#var time = 0
	#var amplitude = 1
	#var frequency = 2
	#time += _delta
	#position.y = sin(time * frequency) * amplitude
	  
	#checks amount reached in path
	if progress_ratio >= 0.3:
		pass
		#print("Reached over 30% of the path")
	

func _on_jellyfish_area_body_entered(body: Node3D) -> void:
	#hopping on jellyfish
	if body is player and !body.diving:
		print("touching jellyfish but not diving!")
	if body is player and body.diving:
		body.linear_velocity.x *= hSpeedMultiplier
		body.linear_velocity.y = bounceForce
		body.linear_velocity.z *= hSpeedMultiplier
		#body.linear_velocity = Vector3.ZERO
		#body.apply_central_impulse(Vector3.UP * 50)
		#TRICK
		print("bounce")
		ScoreManager.give_points(1000, 1, true, "JELLY JUMP")
		%AudioJF.play()
