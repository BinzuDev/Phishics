@tool
extends MultiMeshInstance3D
class_name SeaweedGenerator

@export_tool_button("spawnGeneratorMesh") var action = generateNodes
func generateNodes():
	var copy = get_child(0).duplicate()
	copy.set_name("SeaweedPatchGenerator")
	add_child(copy)
	copy.visible = true
	copy.scale = Vector3(1,1,1)
	copy.owner = get_tree().edited_scene_root

func _ready():
	$Timer.start()

func every_half_second():
	var cam
	var dist
	if Engine.is_editor_hint():
		cam = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
		dist = global_position.distance_to(cam.global_position)
	else:
		cam = get_viewport().get_camera_3d()
		dist = global_position.distance_to(cam.global_position)
		
	
	var ratio = clamp((dist*-0.008)+1.4, 0.2, 1)
	
	multimesh.visible_instance_count = multimesh.instance_count * ratio
	$Label.text = str("dist: ", dist, " ratio: ", ratio, "\ntotal: ", multimesh.instance_count, " visible: ",multimesh.visible_instance_count)
	
