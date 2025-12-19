class_name SkinData extends Resource


@export var name: String
@export var skin: Texture 

@export var unlocked: bool = false

@export_multiline var description: String

# bogus stats
@export var stats: Dictionary[String, String] = {
		"Smell" : "0",
		"Taste" : "0",
		"Floppiness" : "0",
		"Viscosity" : "0",
		"Swimming" : "0",
	}
