@tool
@icon("res://icons/coral.png")
extends Node3D
class_name Coral




@export_tool_button("Generate random color") var action = setRandColor
func setRandColor():
	var hue = randf_range(0.0, 1.0)
	var sat = 0.5
	##Because of the world environment, it makes reds way LESS saturated
	##and teals way MORE saturated, so I have to compensate here
	if (hue > 0.133 and hue < 0.833): #less saturated when blue-green
		sat = 0.4
	else: #more saturated when red
		sat = 0.6
	sat += randf_range(-0.08, 0.08) #extra randomness
	var val = 1.0
	if (hue > 0.45 and hue < 0.547):
		val = 0.85 #darker when perfectly teal
	color = Color.from_hsv(hue, sat, val)
@export_color_no_alpha var color = Color("FFFFFF")
@export var randomColorOnReady : bool = false #new random color every time the level loads


var touched : bool = false
var gibbed : bool = false

func _ready():
	if randomColorOnReady:
		setRandColor()
	toolScript()
	if !Engine.is_editor_hint():
		rotation.y = randf_range(0, 2*PI) #give them a random rotation so they look extra random
		var newScale = randf_range(0.85, 1.15)
		scale = Vector3(newScale,newScale,newScale)
		 
	$CoralTree.visible = true
	$physicsBody.visible = false
	$CoralStem.visible = false
	$physicsBody/BrokenCoral.visible = true
	%gibs.visible = false
	


func _process(_delta):
	if Engine.is_editor_hint():
		toolScript()

func toolScript():
	$CoralTree.get_surface_override_material(0).albedo_color = color




func _on_area_3d_body_entered(body, impact = Vector3.ZERO):
	
	if body == $physicsBody:
		print("cancel, don't let the corel destroy itself")
		return
	
	if body is player:
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
	_on_area_3d_body_entered(null, knockback*30)
