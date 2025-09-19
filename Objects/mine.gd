extends Node3D

@export var force_range = 180

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_mine_touched(body: Node3D) -> void: 
	if body is RigidBody3D:
		for victim in $boomArea.get_overlapping_bodies(): 
			var direction = victim.global_transform.origin - $explosionOrigin.global_transform.origin
			victim.apply_central_impulse(direction.normalized() * force_range) #apply force opposite of mine
			
			if victim is enemy:
				victim.hp = 0 #kill crab
				victim.change_sprite()
			
			
		queue_free()
