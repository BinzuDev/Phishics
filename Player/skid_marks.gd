extends Decal


var timer : int = 0
var theOriginal : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not theOriginal:
		timer += 1
		albedo_mix = (200 - timer) * 0.005
		scale.x = (200 - timer) * 0.0025 + 0.5
		scale.z = (200 - timer) * 0.0025 + 0.5
		if timer == 200:
			queue_free()
	
