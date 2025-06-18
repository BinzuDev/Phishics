extends Area3D

@export var Enables_jump: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body is player: 
		if Enables_jump: 
			body.canJump = true
			print("can jump")
		if Enables_jump == false:
			body.canJump = false 
			print("can't jump")
 
