@tool
@icon("res://Icons/coral.png")
class_name CoralTree extends Coral

var touched : bool = false
var gibbed : bool = false

func _ready():
	super() #calls the ready function of the Coral class
	##don't do this in the editor or else it makes github mad
	if !Engine.is_editor_hint():
		rotation.y = randf_range(0, 2*PI) #give them a random rotation so they look extra random
		var newScale = randf_range(0.85, 1.15)
		scale = Vector3(newScale,newScale,newScale)
		
	
	$CoralTree.visible = true
	$physicsBody.visible = false
	$CoralStem.visible = false
	$physicsBody/BrokenCoral.visible = true
	%gibs.visible = false
	
	#Force the coral to set itself on the floor correctly, so ham stops making them mf floating
	await get_tree().create_timer(0.2).timeout #wait a bit cause collision doesn't exist on the first frame
	if $detectFloor.is_colliding():
		global_position = $detectFloor.get_collision_point()
	



func _on_area_3d_body_entered(body, impact = Vector3.ZERO):
	
	if body == $physicsBody:
		print("cancel, don't let the corel destroy itself")
		return
	
	if body is Player:
		impact = Vector3(body.trueSpeed.x * 3, body.trueSpeed.length() * 2, body.trueSpeed.z * 3) 
	
	
	if not touched:
		$CoralTree.visible = false
		$CoralStem.visible = true
		$physicsBody.visible = true
		$physicsBody.process_mode = Node.PROCESS_MODE_INHERIT
		$physicsBody.apply_central_impulse(impact)
		touched = true
		%crack.play()
		
		await get_tree().create_timer(0.02).timeout #wait a frame before applying torque for consistent results
		$physicsBody.apply_torque_impulse(body.angular_velocity * 0.1)
		
		ScoreManager.give_points(1000, 0, true, "CORAL")
	elif not gibbed: #touched a second time
		ScoreManager.give_points(2000, 0, true, "CORAL")
		
		$physicsBody.process_mode = Node.PROCESS_MODE_DISABLED
		$physicsBody/Area3D.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
		$physicsBody/BrokenCoral.visible = false
		%gibs.visible = true
		$physicsBody/gibs.process_mode = Node.PROCESS_MODE_ALWAYS
		gibbed = true
		%crack.play()
		
		await get_tree().create_timer(0.02).timeout
		for gib in %gibs.get_children():
			gib.apply_central_impulse(impact*0.2)
			gib.apply_central_impulse(Vector3( randf_range(-5,5),randf_range(-1,3),randf_range(-5,5) ))
			gib.apply_torque_impulse(Vector3( randf_range(-10,10),randf_range(-10,10),randf_range(-10,10) ))
		
		##Turn off the node completely after 8s to save on performance
		await get_tree().create_timer(8).timeout
		process_mode = Node.PROCESS_MODE_DISABLED
		$physicsBody/gibs.process_mode = Node.PROCESS_MODE_DISABLED
		$physicsBody/crack.process_mode = Node.PROCESS_MODE_DISABLED
		%gibs.visible = false
		
		

func explode(knockback):
	touched = true
	$CoralTree.visible = false
	$CoralStem.visible = true
	$physicsBody.visible = true
	$physicsBody.process_mode = Node.PROCESS_MODE_INHERIT
	_on_area_3d_body_entered(null, knockback*2)
