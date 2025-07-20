@tool
extends Node3D
@export var lineLength: float = 5.0
@export var reelingSpeed: float = 5.0
var descending: bool = false

var fish : player
var lockFish: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%hookSprite.position.y = -lineLength
	%hookArea.position.y = -lineLength


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		%hookSprite.position.y = -lineLength
		%hookArea.position.y = -lineLength
		
	if lockFish:
		%hookSprite.position.y += reelingSpeed * 0.2
		fish.force_position(%hookSprite.global_position)
		print(reelingSpeed * 0.1)
		if %hookSprite.global_position.y >= global_position.y:
			descending = true
			lockFish = false
			fish.apply_impulse(Vector3(0, 5 * reelingSpeed, 0))
	
	#going down town baby
	if descending:
		%hookSprite.position.y -= reelingSpeed * 0.1
		if %hookSprite.position.y <= -lineLength:
			descending = false





func _on_body_entered(body: Node3D) -> void:
	if body is player:
		if not descending:
			fish = body
			lockFish = true
