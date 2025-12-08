@tool
extends Level


func _ready():
	if !Engine.is_editor_hint():
		super()

var timer : float = 0

func _physics_process(delta):
	timer += 1
	%JFG_dev.rotation_degrees.y += 0.01 / delta
	$UtahTeapot.rotation_degrees.y -= 0.005 / delta
	%LowPolyFish.material_override.uv1_offset.x -= 0.02
	%LowPolyFish.material_override.uv1_offset.y -= 0.005
	%LowPolyFish.rotation_degrees.z += 0.01 / delta
	$BlenderMonkey.position.y = sin(timer*0.02)*35 + 60
	$UtahTeapot.position.y = sin(timer*0.015)*20 + 70
	$fish2/LowPolyFish2.rotation_degrees.y += 0.005 / delta
	$fish2/LowPolyFish2.rotation_degrees.x += 0.02 / delta
	$JFG_flat.position.y = sin(timer*0.01)*5 - 60
	$blahaj.rotation_degrees.y += 0.01 / delta
	%rotating_platform.rotation_degrees.y += 0.2
	
	if !Engine.is_editor_hint():
		$UI/leftSide.visible = !GameManager.hideUI
