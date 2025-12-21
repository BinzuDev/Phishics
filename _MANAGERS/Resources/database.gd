class_name Database extends Resource


@export var skins: Array[SkinData]




func get_skin(id: int) -> SkinData:
	
	if id > skins.size():
		printerr("Index #", id, " is out of bounds in the skin database")
		return
	
	print("get skin: ", skins[id])
	return skins[id]
	
