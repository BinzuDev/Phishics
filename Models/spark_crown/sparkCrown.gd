extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	


var rng
var amp : float = 1.0

func _process(delta):
	amp = max(amp-0.08, 0)
	if amp == 0:
		visible = false
	else:
		visible = true
		$Armature.scale.x += amp*0.04
		$Armature.scale.y += amp*0.04
		$Armature.scale.z += amp*0.04
		print("amp: ", amp, " scale: ", $Armature.scale)
		if GameManager.gameTimer % 3 == 0:
			
			for i in 16:
				if i % 2 == 0:
					rng = randf_range(1, 1+amp)
				else:
					rng = randf_range(1, 1+(amp*0.5) )
				
				var v3 = Vector3(rng,rng,rng)
				$Armature/Skeleton3D.set_bone_pose_scale(i, Vector3(v3))
				
		

func jump(strength):
	strength *= 0.08
	print("jump crown at str ", strength)
	if strength > 1.6:
		amp = strength
		$Armature.scale = Vector3(0.5,0.5,0.5)
