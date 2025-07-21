@tool
extends Node3D


@export var lineLength: float = 10.0
@export var reelingSpeed: float = 3.0
@export_tool_button("Auto set line length") var action = autoLineLength
func autoLineLength():
	$autoSetLength.force_raycast_update()
	var dist = global_position.y - $autoSetLength.get_collision_point().y
	lineLength = dist - 0.8
	



var fish : player
var lockFish: bool = false
var descending: bool = false




## Set hook position when game starts
func _ready() -> void:
	%hookSprite.position.y = -lineLength
	%hookArea.position.y = -lineLength
	


func _process(delta: float) -> void:
	
	## Set the hook position if inside the editor
	if Engine.is_editor_hint():
		%hookSprite.position.y = -lineLength
		%hookArea.position.y = -lineLength
	
	## When the fish is on the hook
	if lockFish:
		%hookSprite.position.y += reelingSpeed * 0.2
		fish.force_position(%hookSprite.global_position)
		
		## When hook reached the top
		if %hookSprite.global_position.y >= global_position.y:
			descending = true
			lockFish = false
			fish.isHeld = false #prevents tip landing
			fish.apply_impulse(Vector3(0, 5 * reelingSpeed, 0))
	
	#going down town baby
	if descending:
		%hookSprite.position.y -= reelingSpeed * 0.1
		if %hookSprite.position.y <= -lineLength:
			descending = false
			%hookArea.set_collision_layer_value(6, true)



## When fish touches hook
func _on_body_entered(body: Node3D) -> void:
	if body is player:
		if not descending:
			fish = body
			lockFish = true
			fish.isHeld = true #prevents tip landing
			%hookArea.set_collision_layer_value(6, false)
