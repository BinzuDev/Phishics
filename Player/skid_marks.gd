extends Decal
class_name skidMarkDecals

var timer : int = 0
var theOriginal : bool = true


func _process(_delta):
	if not theOriginal:
		timer += 1
		albedo_mix = (250 - timer) * 0.004
		#scale.x = (200 - timer) * 0.0025 + 0.5
		#scale.z = (200 - timer) * 0.0025 + 0.5
		if timer == 250:
			queue_free()
	
