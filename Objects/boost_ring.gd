@icon("res://icons/boost_ring.png")
@tool #this makes it so code can run in the editor
class_name boostRing
extends Area3D

@onready var particles = $ring/CPUParticles3D

@export_range(5, 40, 0.1, "or_greater") var strength : float = 10
@export var centerPlayer : bool = false ##Forces the player to get centered when precision is needed
@export var rotating : bool = false #new rotation option
@export var rotationSpeed : float = 1.0
@export var deactivateParticles : bool = false
@export var targetableByHoming : bool = true
@export var affectFreshness : bool = true

var strengthLastFrame = strength

#We need a cooldown because sometimes you can hit the same boost multiple frames in
#a row if you're unlucky rotation, but we can't make the cooldown affect the boost
#itself because a boost is used to block your way and we dont want it to be easier
#to cheese through it
var freshCooldown := 0


func _ready():
	if targetableByHoming == false:
		$homingTarget.collision_layer = 0

func _process(_delta: float) -> void:
	freshCooldown += 1
	$ring.rotation.x += 0.02
	$direction.scale.x = strength
	if !Engine.is_editor_hint(): #hide the helper arrow in game
		$direction.visible = false
	
	#I have to do this stupidness because the particles reset every time the Amount value is changed
	#So if I change it every frame it'll constantly reset and nothing will spawn
	if strengthLastFrame != strength:
		particles.amount = int(strength) * 2
	strengthLastFrame = strength
	
	
	particles.initial_velocity_min = strength * 1.5 -1
	particles.initial_velocity_max = strength * 1.5 +1
	particles.linear_accel_min = strength * -1 -1
	particles.linear_accel_max = strength * -1 +1
	
	
	
	if rotating: #checks for rotation value
		rotation_degrees.y += rotationSpeed
	

	$ring/CPUParticles3D.emitting = !deactivateParticles
	
	


func _on_body_entered(body: Node3D) -> void:
	if body is RigidBody3D:
		
		
		if centerPlayer:
			body.global_position = global_position
		
		body.linear_velocity = Vector3(0,0,0)
		body.angular_velocity = Vector3(0,0.1,0)
		
		var distance = %goal.global_position - global_position
		
		distance.y += 1 #slight upward boost to counter gravity
		
		body.apply_torque_impulse(distance)
		body.apply_impulse(distance*3)
		
		
		if body is player:
			ScoreManager.reset_airspin()
			ScoreManager.give_points(500, 1, true, "BOOST")
			if affectFreshness and freshCooldown >= 4:
				ScoreManager.update_freshness(self)
				freshCooldown = 0 
			ScoreManager.play_trick_sfx("rare")
			$AnimationPlayer.play("boost")
		#body.play_random_trick()
		
		#sound 
		$BoostSound.play() 
