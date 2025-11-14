extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	$Armature.scale = Vector3(0.5,0.5,0.5)
	

var amp : float = 1.0
var lerpAmp : float = 1.0 #moves towards amp
var startingAmp : float = 1.0 #the initial amp value
var sparkTier : int = 0

func _process(delta):
	amp = max(amp-0.11, 0)
	if amp == 0:
		visible = false
	else:
		visible = true
		$Armature/Skeleton3D.scale = lerp_scale() * 1.0
		$Armature/Skeleton2.scale = lerp_scale() * 1.2
		$Armature/Skeleton3.scale = lerp_scale() * 1.4
		
		lerpAmp = move_toward(lerpAmp, amp, 0.4)
		if GameManager.gameTimer % (4-sparkTier) == 0:
			for i in 16:
				$Armature/Skeleton3D.set_bone_pose_scale(i, vec3_rng(i))
				$Armature/Skeleton2.set_bone_pose_scale(i, vec3_rng(i))
				$Armature/Skeleton3.set_bone_pose_scale(i, vec3_rng(i))
				
		#print("amp: ", snapped(amp, 0.01), " lamp: ", snapped(lerpAmp, 0.01),
		#   " scale y: ",snapped($Armature/Skeleton3D.scale.x, 0.01), "  p: ", snapped($Armature/Skeleton2.scale.x, 0.01), "  b: ", snapped($Armature/Skeleton3.scale.x, 0.01) )

func lerp_scale():
	var newScale = $Armature/Skeleton3D.scale.x
	#newScale += 0.25
	newScale = lerp(newScale, startingAmp+1, 0.15 )
	newScale = Vector3(newScale,newScale*0.4,newScale)
	return newScale


func vec3_rng(i):
	var rng
	if i % 2 == 0:
		rng = randf_range(1, 1+lerpAmp*1.5)
	else:
		rng = randf_range(1, 1+(lerpAmp*0.75) )
	return Vector3(1,rng,1)

func jump(strength):
	strength *= 0.08
	print("jump crown at str ", strength)
	if strength >= 1.6:
		$Armature/Skeleton3D.scale = Vector3(0.1,0.1,0.1)
		$Armature/Skeleton2.visible = false
		$Armature/Skeleton3.visible = false
		amp = clamp(strength, 0, 4)
		startingAmp = amp
		lerpAmp = 0
		sparkTier = 0
		if strength >= 2: #25 * 0.08 = 2
			$Armature/Skeleton2.visible = true
			sparkTier = 1
			ScoreManager.play_trick_sfx("legendary")
		if strength >= 3.5:
			$Armature/Skeleton3.visible = true
			sparkTier = 2
			

#%Torus.material_override.albedo_color = Color(1.0, 0.29, 1.0, 1.0)
#%Torus.material_override.albedo_color = Color(1.0, 1.0, 0.0, 1.0)
#%Torus.material_override.albedo_color = Color(0.0, 1.0, 1.0, 1.0)
