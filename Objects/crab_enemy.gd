@icon("res://Icons/crab.png")
class_name CrabEnemy extends RigidBody3D

#rave
@onready var animation_crab : AnimationPlayer = $AnimationCrab 

enum Enum1 {Regular_Crab, Horse_Shoe}
@export var enemyType:Enum1


var og_position
var target = 0
var agro : bool = false
var speed := 2
var hp := 2
var shiny :bool = false
var airborneByBoostRing : bool = false

var crackedSprite


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	og_position = position #stores it's position so it can return to it if it moves
	
	
	#enemy type loads
	if enemyType == Enum1.Horse_Shoe:
		$CrabSprite.texture = load("res://Sprites/crabs/horseshoecrab.png")
	
	#preload cracked sprite
	var sprite_name = $CrabSprite.texture.resource_path.get_file().get_basename()
	var cracked_path = "res://Sprites/crabs/" + sprite_name + "cracked.png"
	
	#checks if name exists then changes sprite to sprite name + cracked
	if ResourceLoader.exists(cracked_path):
		crackedSprite = load(cracked_path)
	
	
	
	#shiny chance
	var chance := randi_range(1, 400)
	
	if chance == 1:
		$CrabSprite.modulate = Color(0, 1, 1)  # Sets the sprite to blue
		shiny = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	#print("scale is", scale)
	#var direction = (player.global_transform.origin - global_transform.origin).normalized()
	if agro:
		apply_central_impulse(target * 0.5)
		#get_parent().apply_central_impulse(direction * 5 * delta)
		
		
		#Checking if on floor and eneabling area 3d/disabling it
	if $FloorCast.is_colliding() and hp > 0:
		#print("enemy floored")
		$Area3D.monitoring = true
		$CrabSprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		
	else:
		$Area3D.monitoring = false
		#$CrabSprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	
	#reset rave
	if agro:
		%AnimationCrab.play("RESET")
	
	#ensure ragdoll death
	if hp <= 0:
		$CrabSprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
		$homingTarget.priority = -1 #lower the target priority of dead crabs
	#print("scale is2", scale)
	
	if $FloorCast.is_colliding():
		airborneByBoostRing = false #stops the boost ring airshot nerf
	


## Enemy detect
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		
		#print("detected")
		agro = true
		
		var direction = global_transform.origin.direction_to(body.global_transform.origin)
		target = direction
		#apply_central_impulse(direction * 2)
		apply_central_impulse(Vector3(0, 7, 0)) #jump
		
		
		var torque_axis = direction.cross(Vector3.UP)  # Calculate a perpendicular axis
		apply_torque(torque_axis * 10)
		
	
	#if $FloorCast.is_colliding():
		#$JumpPuff.emitting = true
		
	



func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		#print("left detection")
		
		var direction = global_transform.origin.direction_to(body.global_transform.origin)
		target = direction
		agro = false
		apply_central_impulse(direction * 3)
		
		


## When the fish and crab touch eachother
func _on_bump_body_entered(body: Node3D) -> void:
	#because the gravity gets turned off when the fish is homing
	#so it doesnt fall out of the way
	gravity_scale = 1
	
	print("---------------------------------")
	print("BUMP BODY ENTERED ON ", name)
	print("SPD IS: ", body.linear_velocity, " ", body.linear_velocity.length())
	
	#horsehoe crabs can only be damaged if diving
	if enemyType == Enum1.Horse_Shoe and not body.diving:
		if hp > 0:
			#Push opposite side
			var push_direction = -body.linear_velocity.normalized()
			var push_force = 30.0
			#
			body.apply_central_impulse(push_direction * push_force)
			
			#Upwards force
			body.apply_central_impulse((-body.linear_velocity.normalized() + Vector3.UP * 0.5) * push_force)
			#
			#"ragdoll" push
			$CrabSprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
			apply_torque(Vector3(0, 10, 0))
	
	
	#regular crab logic
	if body.linear_velocity.length() < 6 and not body.isTipSpinning:
		print("PUSHING THE PLAYER AWAY FROM MOVING AT LESS THAN 4")
		if hp > 0:
			print("WEAK")
			
			#Push opposite side
			var push_direction = -body.linear_velocity.normalized()
			var push_force = 30.0
			#
			body.apply_central_impulse(push_direction * push_force)
			
			#Upwards force
			body.apply_central_impulse((-body.linear_velocity.normalized() + Vector3.UP * 0.5) * push_force)
			#
	
	#damage the crab
	if body.linear_velocity.length() >= 6 or body.isTipSpinning:
		print("ATTACKING THE CRAB CAUSE SPEED IS HIGHER THAN 6")
		
		if enemyType == Enum1.Regular_Crab: #regular crab logic
			#player pushing
			var push_force = 30.0
			#
			var push_direction = body.linear_velocity.normalized()
			self.apply_central_impulse(push_direction * push_force)
			
			#"ragdoll"
			$CrabSprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
			apply_torque(Vector3(0, 10, 0))
		
		
		
		if hp > 0:
			
			#Audio for bumps
			if enemyType == Enum1.Horse_Shoe and body.diving:
				$AudioStreamPlayer3D.play()
			
			if enemyType == Enum1.Regular_Crab:
				$AudioStreamPlayer3D.play()
			
			
			if not body.diving and enemyType == Enum1.Regular_Crab:
				#trick
				ScoreManager.give_points(800, 0, true, "CRAB TOSS")
				#$AudioStreamPlayer3D.play()
				#body.body.func_set_fov()
			
		else:
			ScoreManager.give_points(100, 0, false, "DISRESPECT")
			
			#body.play_trick_sfx("rare")
		
		#diving pogo
		if body.diving:
			body.linear_velocity.x *= 0.4
			body.linear_velocity.y = 20
			body.linear_velocity.z *= 0.4
			
			if $FloorCast/airshot.is_colliding() or airborneByBoostRing: #nerfs airshot in THE PIT
				if hp == 2:
					ScoreManager.give_points(1000, 0, true, "HOMING ATTACK")
				if hp == 1:
					ScoreManager.give_points(2000, 1, true, "HOMING ATTACK")
				ScoreManager.update_freshness(self)
			else:
				ScoreManager.give_points(0, 5, true, "HOMING AIRSHOT")
				ScoreManager.update_freshness(self)
				ScoreManager.play_trick_sfx("rare")
				 
		
		
		
		if enemyType == Enum1.Regular_Crab:
			hp -= 1 #minus hp
		
		if enemyType == Enum1.Horse_Shoe and body.diving:
			hp -= 1 #minus hp
		
		change_sprite()


func change_sprite():
	#cracked sprite
	if hp <= 1: 
		$CrabSprite.texture = crackedSprite
	if hp <= 0: 
		#scale collsion shape so carb is flat
		$CollisionShape3D.scale.z = 0.3 
		
		$CrabSprite.modulate = Color(0.5, 0.5, 0.5, 1)
		if shiny:
			$CrabSprite.modulate = Color(0.0, 0.29, 0.47, 1)
			
	%AnimationCrab.play("RESET") #no more immortal dancer


func _on_getting_parried(area):
	hp = 0
	change_sprite()
	get_tree().get_first_node_in_group("player").play_shock_wave()
	var direction = global_transform.origin - area.global_transform.origin
	direction = direction.normalized()
	direction = Vector3(direction.x*20, abs(direction.y*25), direction.z*20)
	apply_central_impulse(direction)
	apply_torque_impulse(Vector3(5, 3, 5))
