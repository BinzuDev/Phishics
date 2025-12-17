extends Decal
class_name EnvironmentalDecal

var timer : int = 0
var theOriginal : bool = true
var fadeTime = 250


func _process(_delta):
	if not theOriginal: #starwalker
		timer += 1
		#albedo_mix = (250 - timer) * 0.004
		albedo_mix = (fadeTime - timer) * (1/float(fadeTime))
		#scale.x = (200 - timer) * 0.0025 + 0.5
		#scale.z = (200 - timer) * 0.0025 + 0.5
		if timer >= fadeTime:
			queue_free()
	


func setup_decal(newPosition: Vector3, surfaceNormal: Vector3, newSize : float,
				 fadeOutTime : int = 250, startingFade : int = 0):
	theOriginal = false
	global_position = newPosition
	#set the angle with complicated math
	global_transform.basis.y = surfaceNormal
	global_transform.basis.x = -global_transform.basis.z.cross(surfaceNormal)
	global_transform.basis = global_transform.basis.orthonormalized()
	size.x = newSize
	size.z = newSize
	fadeTime = fadeOutTime
	timer = startingFade
	visible = true
