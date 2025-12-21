class_name Database extends Resource


@export var skins: Array[SkinData]




func get_skin(id: int):
	
	if id > skins.size():
		printerr("skin out of bounds")
		return
	
	print("get skin: ", skins[id])
	return skins[id]
	
