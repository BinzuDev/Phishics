extends Sprite3D

var timer = 0
var min_scale = 0.7
var max_scale = 0.8
var speed = 8
@export_file("*.ogg") var audio_file: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Loads the export file
	if audio_file:
		var audio_stream = load(audio_file)
		if audio_stream:
			%Tunes.stream = audio_stream
			%Tunes.play()
	else:
		print("Error loading audio file: ", audio_file)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta * speed
	var scale_value = min_scale + (max_scale - min_scale) * (sin(timer) + 1) / 2
	scale = Vector3(scale_value, scale_value, scale_value)
	
	
	
	
	
	
	
	#for body in $RaveArea.get_overlapping_bodies():
		#if "agro" in body and not body.agro:
			#body.animation_crab.play("RAVE")

	
	


func _on_rave_area_body_entered(body: Node3D) -> void:
	#RAVE
	if body is CrabEnemy and not body.agro and body.hp > 0:
		body.animation_crab.play("RAVE")




func _on_rave_area_body_exited(body: Node3D) -> void:
	if body is CrabEnemy and not body.agro:
		body.animation_crab.play("RESET")
