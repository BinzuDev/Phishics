@tool
@icon("res://icons/railGrind.png")
class_name railGrind
extends PathFollow3D

@export var invisibleRail : bool = false ##If you want to make a railgrind area on an existing piece of geometry, and don't need the pipe.
@export var faceStraightAhead : bool = false ##Makes the surfboard point forward instead of at an angle
@export var oneWay : bool = false ##The rail will always make you move in the FORWARD direction (in the order of the points in the curve3D)

var isBeingUsed: bool = false #if the fish is currently using this rail
var fish: player
var path_3d: Path3D #the parent path object of railgrind
var mountingCooldown = 0 #cooldown after unmounting
var mountingSpeed #How fast the fish was going when mounting
var progress_last_frame := 0.0 #used to figure out in which direction the hitbox is moving
var direction := "forward"

func _ready():
	
	#print("getting rail grind parent")
	if get_parent() is Path3D: #get the path3d parent, with a proper safety net
		$railMetal.path_node = get_parent().get_path()
		toolScript() #sets the railpipe model
		path_3d = get_parent()
		loop = path_3d.curve.closed #make the railgrind not loop around 
	elif !Engine.is_editor_hint():
		printerr("RAILGRIND OBJECT \"", name, "\" IS A CHILD OF \"", get_parent().name, "\", WHICH IS NOT A PATH3D NODE, STOPPING PROCESS.")
		process_mode = Node.PROCESS_MODE_DISABLED #the safety net in question
	
	if oneWay:
		$HomingTargetBack.set_collision_layer_value(6, false)
	
	
	if !Engine.is_editor_hint(): #when playing the game
		fish = get_tree().get_first_node_in_group("player") #get the fish
		if !get_tree().debug_collisions_hint: #if "visible collision shapes" is off
			$debugStuff.visible = false #hide the debug visuals in game
	



##TODO: needs sound effects
##TODO: jumping off of a rail thats close to the ground counts as a pogo jump?????

##NOTICE: using fish.trueSpeed, you can now get how fast the fish is ACTUALLY moving, use this instead of linear_velocity for calculations.
##fish.trueSpeed is a Vector3, so just like with with velocity, you can use fish.trueSpeed.length() to get the total speed without direction
##(this is a getter only variable, setting it does NOTHING)
##(you can monitor the value by turning on surf debug)


## Sets the rail pipe
func toolScript():
	if get_parent() is Path3D:
		$railMetal.global_transform = get_parent().global_transform
	$railMetal.visible = !invisibleRail
	$debugStuff/oneWayDirection.visible = oneWay

func _process(delta):
	if Engine.is_editor_hint():
		toolScript()
	else:
		real_process(delta)

func real_process(delta):
	## When NOT railgrinding
	#Makes the hitbox be as close as possible to the fish, while staying on the path
	if fish and path_3d and not isBeingUsed:
		progress_last_frame = progress
		var target_position = path_3d.to_local(fish.global_position) #calculate where the fish is
		var closest_offset = path_3d.curve.get_closest_offset(target_position) #calculate where the hitbox should move
		self.progress = closest_offset #move hitbox
		#set the movement direction by comparing where it was last frame to where it is now
		if (progress - progress_last_frame) > 0 or progress_ratio == 0.0: 
			direction = "forward" 
		elif (progress - progress_last_frame) < 0 or progress_ratio == 1.0: 
			direction = "backward"
		#if its exactly 0 then dont change
		if oneWay:
			direction = "forward" 
		
	
	##Move the homing hitbox to the center when at the very end
	if progress_ratio == 0 or progress_ratio == 1:
		$HomingTargetFront.position.z = 0
		$HomingTargetBack.position.z = 0
	else:
		$HomingTargetBack.position.z = -2.5
		$HomingTargetFront.position.z = 2.5
	
	
	
	
	## All the code that should run during railgrinding
	if isBeingUsed:
		ScoreManager.give_points(mountingSpeed*6, 0, false, "RAILGRIND") #gives points every frame
		
		lock_fish_in_place() #put the fish above the rail
		
		ScoreManager.comboTimer += 0.33 #Make the combo timer go down 33% slower
		
		## Movement
		if direction == "forward":
			self.progress += mountingSpeed*delta #*delta so its not slower at low fps
		else:
			self.progress -= mountingSpeed*delta
		
		#unmount by jumping                      #prevents unmounting immediatly if you were spamming jump
		if Input.is_action_just_pressed("jump") and mountingCooldown == 0:
			unmount()
			fish.apply_impulse(Vector3(0,20,0)) #jump off
		
		#unmount if you reach the end (unless its a closed loop)
		if (progress_ratio == 0.0 or progress_ratio == 1.0) and !path_3d.curve.closed:
			unmount()
			
		
		
	
	#debug info
	debug_stuff()
	
	
	if isBeingUsed:
		mountingCooldown = min(mountingCooldown+1, 0) #go up but stop at 0
	else:
		mountingCooldown += 1


## When the fish touches the path
func _on_area_entered(body):
	if body is player and fish.surfMode:
		
		if mountingCooldown > 15: #so you can't reenter this railgrind for 0.25s after leaving it
			
			if mountingCooldown > 40:
				ScoreManager.update_freshness(self) #freshness
			if mountingCooldown > 100:
				ScoreManager.give_points(0, 2, true, "RAILGRIND") #trick
				ScoreManager.play_trick_sfx("rare") #trick sfx
				mountingCooldown = -15 #stops you from unmounting for 15 frames in case you were spamming jump
			else:
				mountingCooldown = 0
			isBeingUsed = true
			fish.isRailGrinding = true
			fish.reparent(self) #make the fish a child of the railgrind object
			fish.surfRotationType = ""
			fish.inputHistory = ["","",""] #reset a bunch of stuff
			
			if fish.currentRailObj != null: #touching a railgrind on a railgring
				fish.currentRailObj.isBeingUsed = false #deactivate the old railgrind
			fish.currentRailObj = self #set the the current activated railgrind to itself
			
			ScoreManager.reset_airspin()
			
			lock_fish_in_place()
			var hspeed = Vector2(fish.trueSpeed.x, fish.trueSpeed.z) #remove Y speed from the equation
			if fish.homing:
				hspeed *= 0.5
			
			mountingSpeed = clamp(hspeed.length()*1.2, 13, 60)  ##sets how fast you'll move on the rail (with clamps)
			
			fish.posLastFrame = fish.global_position ##stops trueSpeed from becoming absurdly high from the instant teleportation
			fish.posLastFrame.x += hspeed.length()/60   #modifiy posLastFrame so trueSpeed isnt 0 either, so you keep your overall speed
			
			


## Makes the fish unmount the rail and return to normal
func unmount():
	isBeingUsed = false
	fish.isRailGrinding = false
	fish.currentRailObj = null
	fish.reparent(get_tree().get_current_scene()) #make the fish a child of the level
	fish.linear_velocity = Vector3(0.001,0.001,0.001)
	fish.linear_velocity = fish.trueSpeed*1.2 #true speed (might be a bit redunant)

## Sets where the fish is going to be relative to the rail
func lock_fish_in_place():
	fish.position = Vector3(0,0.5,0)
	fish.rotation_degrees = Vector3(0,0,0)
	if direction == "backward": #if backwards, face the other way
		fish.rotation_degrees = Vector3(0,180,0)
	if !faceStraightAhead: #turn 45 degrees unless faceStraightAhead is on
		fish.rotation_degrees.y -= 45
	
	
	
	fish.linear_velocity = Vector3(0.001,0.001,0.001)
	fish.angular_velocity = Vector3(0.001,0.001,0.001)


func debug_stuff():
	$debugStuff/Label.text = str("Prog: ", snapped(progress_ratio*100, 0.01), "%", 
						"\nCooldown: ", mountingCooldown, 
						"\nDirection: ", direction, " (", progress - progress_last_frame, ")",
						"\nSpeed: ", mountingSpeed)
	$debugStuff/Visual.material_override.albedo_color = Color("ff0000")
	if isBeingUsed:
		$debugStuff/Visual.material_override.albedo_color = Color("00ff00")
