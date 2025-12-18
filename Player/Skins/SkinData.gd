extends Resource

class_name SkinData


@export var name: String
@export var skin: Texture 

@export var unlocked: bool = false

@export_multiline var description: String

# bogus stats

@export_group("Stats")
@export var smell: int = 0
@export var style: int = 0
@export var moist: int = 0
@export var fishiness: int = 0
@export var silliness: int = 0
