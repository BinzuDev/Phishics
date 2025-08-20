@icon("res://icons/worm.png")
extends Area3D

var collected: bool = false



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not collected:
		$wormsprite.rotation.y += 0.09 #rotation
	


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is player and not collected:
		ScoreManager.give_points(800,5,true, "WORM")
		ScoreManager.update_freshness(self)
		collected = true
		$WormSFX.play()
		$WormAnimation.play("Collected") #animation


func _on_air_hitbox_body_entered(body):
	if body is player and not collected:
		if body.height > 10: #if the player enters the big hitbox while up in the air
			print("COLLECTED WORM IN THE AIR")
			_on_area_3d_body_entered(body) #run the regular function
