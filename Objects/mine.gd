@icon("res://icons/mine.png")
@tool
class_name Mine
extends Node3D

@export var explosionStrength : int = 600 ##Knockback force (can't be changed directly) 
@export_range(5, 50, 1.0, "or_greater") var explosionRadius : float = 25
@export_range(0.1, 3, 0.1, "or_greater") var knockbackMultiplier : float = 1.0
@export var homingTarget : bool = true
@export var previewExplosionSize : bool = false

var isExploding : bool = false
var timer : int = 0

##the math formula for the explosion is:
##y = (r*25*m) / x
##y: final knockback
##x: distance to the mine (the ACTUAL center, not the the fake origin used for the angle)
##r: radius of the explosion
##m: multiplier

func _ready() -> void:
	previewExplosionSize = false
	toolScriptShit()
	$detectFloor.add_exception($base/StaticBody3D)#cause the raycase to not detect the base
	if !Engine.is_editor_hint():
		$hitArea.set_collision_layer_value(6, homingTarget)


##Set all of the tool script stuff
func toolScriptShit():  #1000 at 40, 500 at 20 etc
	explosionStrength = explosionRadius * 25 * knockbackMultiplier
	$detectFloor.force_raycast_update()
	$base.global_position = $detectFloor.get_collision_point()
	$preview.visible = previewExplosionSize
	$boomArea/CollisionShape3D.shape.radius = explosionRadius
	$preview.scale = vec3(explosionRadius)
	$explosion.scale = vec3(explosionRadius)
	if previewExplosionSize:
		$explosion.frame = 5
	else:
		$explosion.frame = 23
		
	


func _process(_delta: float) -> void:
	if !Engine.is_editor_hint(): #when in game
		if isExploding:
			timer += 1   #advance the animation one frame every 4 frames
			if timer % 4 == 0 and $explosion.frame < 23: 
				$explosion.frame += 1
	else:
		toolScriptShit()



## When something touches the mine
func _on_mine_touched(body: Node3D) -> void: 
	if body is RigidBody3D:
		if body is player and body.homing:
			_on_animation_finished("diving") #explode instantly when diving
		else:
			activate_mine()
	

## Start the pin clicking animation
func activate_mine(chainReaction:bool = false):
	if !isExploding and !$AnimationPlayer.is_playing():
		$AnimationPlayer.play("click")
		if chainReaction:
			ScoreManager.give_points(0, 2, true, "CHAIN REACTION")
		



## When the pin animation is finished
func _on_animation_finished(_anim_name):
	ScoreManager.give_points(9999, 0, true, "KABOOM")
	$explosion.frame = 0
	$sphere.visible = false
	$StaticBody3D.process_mode = Node.PROCESS_MODE_DISABLED #disable collision
	$hitArea.set_collision_layer_value(6, false) #so it can't be targeted during the explosion
	$explosion_sfx.play()
	isExploding = true
	
	for otherArea in $boomArea.get_overlapping_areas(): #explode any area on layer 7
		if otherArea.get_parent() is Mine:
			otherArea.get_parent().activate_mine(true)
			
		if otherArea.get_parent() is bowlingPins:
			otherArea.get_parent().strike(explosionStrength * 0.05) #strikes the bowling pins
	
	for victim in $boomArea.get_overlapping_bodies(): #give knockback to detected physics objects
		var direction = victim.global_transform.origin - $explosionOrigin.global_transform.origin #go higher on average
		if _anim_name == "diving": #keep your forward momentum when diving
			direction.x *= -1
			direction.z *= -1
			victim.linear_velocity.y = 0
		else:
			victim.linear_velocity = Vector3(0.001, 0.001, 0.001) #surf glitch prevention
		var knockback = victim.global_transform.origin - global_transform.origin #use the actual origin to calculate distance
		knockback = max(knockback.length(), 5) #cap at 5 if any closer
		knockback = explosionStrength/knockback 
		victim.apply_central_impulse(direction.normalized() *  knockback) #apply force opposite of mine that gets weaker with distance
		print("distance to ", victim.name, ": ", (victim.global_transform.origin - global_transform.origin).length(), ", knockback received: ", knockback )
		
		if victim is enemy:
			victim.hp = 0 #kill crab
			victim.change_sprite()
			victim.apply_torque_impulse(Vector3(5, 3, 5))
		

## When the explosion sfx is done playing
func _on_explosion_finished():
	#Pause the node instead of deleting it, 
	#this saves on performance while still allowing freshness interaction to work
	if !Engine.is_editor_hint():
		process_mode = Node.PROCESS_MODE_DISABLED


#cleanly make a vector 3 with a uniform scale
func vec3(size:float):
	return Vector3(size,size,size)
