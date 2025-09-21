@tool
@icon("res://icons/hook.png")
extends Node3D

@export_tool_button("Auto set line length") var action = autoLineLength
func autoLineLength():
	$autoSetLength.force_raycast_update()
	var dist = global_position.y - $autoSetLength.get_collision_point().y
	lineLength = dist - 0.8
@export var lineLength: float = 10.0
@export_range(0.5, 3, 0.01, "or_greater", "suffix:x") var reelingSpeed: float = 1.0
@export var homingTarget : bool = true




var fish : player
var lockFish: bool = false
var descending: bool = false
#Remember the fish's rotation speed to give it back to him after
var storeFishSpeed : Vector3 
#So that the reeling can ba slightly gradual
var actualSpeed: float = 1.0
var fastAccel : bool = false #accelerate faster when diving on the hook
var timer : int = 0

## Set hook position when game starts
func _ready() -> void:
	set_hook_lenght()
	%hookArea.set_collision_layer_value(6, true)

## Function so no repeating code
func set_hook_lenght():
	%hookSprite.position.y = -lineLength
	%hookArea.position.y = -lineLength


func _process(_delta: float) -> void:
	
	## Set the hook position if inside the editor
	if Engine.is_editor_hint():
		set_hook_lenght()
	
	
	timer += 1
	#var swaySpd = 2
	#var swayAmt = 2
	#%hookSprite.position.x = sin(timer*swaySpd*0.1) * swayAmt
	#%hookSprite.rotation_degrees.z = %hookSprite.position.x*14
	
	
	## When the fish is on the hook
	if lockFish:
		#what makes it accelerate at the start
		if fastAccel:
			actualSpeed = min(actualSpeed*2, 1.0)
		else:
			actualSpeed = min(actualSpeed*1.3, 1.0)
		#print(actualSpeed)
		%hookSprite.position.y += reelingSpeed * 0.6 * actualSpeed
		fish.force_position(%hookSprite.global_position)
		ScoreManager.comboTimer += 1 #so you dont lose your combo on long hooks
		
		## When hook reached the top
		if %hookSprite.global_position.y >= global_position.y:
			lockFish = false
			fish.isHeld = false #prevents tip landing
			fish.apply_impulse(Vector3(0, 25 * reelingSpeed, 0))
			fish.angular_velocity = storeFishSpeed
			%sfxEnd.play()
			%sfxLoop.stop()
			$AnimationPlayer.play("reel_end")
			%hookSprite.position.y = 0 #reset position if overshoot
	
	## When going back down
	if descending:
		%hookSprite.position.y -= reelingSpeed * 0.4
		## When the bottom has been reached
		if %hookSprite.position.y <= -lineLength:
			descending = false
			%hookArea.set_collision_layer_value(6, true)
			set_hook_lenght() #in case it overshoots
	
	## set the length of the wire
	$aaaaWire.scale.y = -%hookSprite.position.y
	
	if !homingTarget:
		%hookArea.set_collision_layer_value(6, false)


## When fish touches hook
func _on_body_entered(body: Node3D) -> void:
	if body is player:
		if not descending and !$AnimationPlayer.is_playing():
			fish = body
			lockFish = true
			fish.isHeld = true #prevents tip landing
			storeFishSpeed = fish.angular_velocity
			ScoreManager.give_points(500, 1, true, "HOOKED")
			ScoreManager.update_freshness(self)
			%hookArea.set_collision_layer_value(6, false)
			%sfxStart.play()
			%sfxLoop.pitch_scale = reelingSpeed
			%sfxLoop.play()
			actualSpeed = 0.03
			fastAccel = fish.diving
			


func _on_animation_finished(_anim_name):
	descending = true #only start going down after animation done
