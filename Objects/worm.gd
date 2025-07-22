extends Area3D

var collected: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not collected:
		%wormsprite.rotation.y += 0.09 #rotation
	


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is player and not collected:
		print("got worm!")
		ScoreManager.give_points(800,5,true, "WORM")
		
		collected = true
		
		%WormSFX.play() #SFX
		
		%WormAnimation.play("Collected") #animation
