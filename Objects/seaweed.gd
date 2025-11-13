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
