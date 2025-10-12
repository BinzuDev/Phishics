@icon("res://icons/railGrind.png")
class_name railGrind
extends PathFollow3D

var isBeingUsed: bool = false #if the fish is currently using this rail
var fish: player
var path_3d: Path3D #the parent path object of railgrind
var mountingCooldown = 0 #cooldown after unmounting
var mountingSpeed #How fast the fish was going when mounting
var progress_last_frame #used to figure out in which direction the hitbox is moving
var direction := "forward"

func _ready():
	fish = get_tree().get_first_node_in_group("player") #get the fish
	if get_parent() is Path3D: #get the path3d parent, with a proper safety net
		path_3d = get_parent()
		loop = path_3d.curve.closed #make the railgrind not loop around 
	else:
		printerr("RAILGRIND OBJECT \"", name, "\" IS A CHILD OF \"", get_parent().name, "\", WHICH IS NOT A PATH3D NODE, STOPPING PROCESS.")
		process_mode = Node.PROCESS_MODE_DISABLED #the safety net in question


##TODO: trick that gives mult when you mount, then trick that gives points every frame during railgrind
##TODO: when unmounting, you should keep your momentum (use fish.trueSpeed to set fish.linear_velocity)
##TODO: clamp mountingSpeed to your liking so there's a minimum speed 
##TODO: Use the tutorial to learn how to generate rail meshes from a path node
##TODO: homing diving during railgrind is uhhhh.......

##TODO: READ THIS 🡇🡇🡇🡇🡇🡇🡇🡇🡇🡇🡇🡇
##NOTICE: using fish.trueSpeed, you can now get how fast the fish is ACTUALLY moving, use this instead of linear_velocity for calculations.
##fish.trueSpeed is a Vector3, so just like with with velocity, you can use fish.trueSpeed.length() to get the total speed without direction
##(this is a getter only variable, setting it does NOTHING)
##(you can monitor the value by turning on surf debug)

func _process(delta):
	
	## When NOT railgrinding
	#Makes the hitbox be as close as possible to the fish, while staying on the path
	if fish and path_3d and not isBeingUsed:
		progress_last_frame = progress
		var target_position = path_3d.to_local(fish.global_position) #calculate where the fish is
		var closest_offset = path_3d.curve.get_closest_offset(target_position) #calculate where the hitbox should move
		self.progress = closest_offset #move hitbox
		#set the movement direction by comparing where it was last frame to where it is now
		if (progress - progress_last_frame) >= 0: 
			direction = "forward" 
		else:
			direction = "backward"
		
	
	## All the code that should run during railgrinding
	if isBeingUsed:
		lock_fish_in_place() #put the fish above the rail
		
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
		if mountingCooldown > 60: #so you can't reenter this railgrind for 1s after leaving it
			mountingCooldown = -20 #stops you from unmounting for 20 frames in case you were spamming jump
			isBeingUsed = true
			fish.isRailGrinding = true
			fish.reparent(self) #make the fish a child of the railgrind object
			fish.surfRotationType = ""
			fish.inputHistory = ["","",""] #reset a bunch of stuff
			ScoreManager.reset_airspin()
			ScoreManager.update_freshness(self) #freshness
			lock_fish_in_place()
			var hspeed = Vector2(fish.trueSpeed.x, fish.trueSpeed.z) #remove Y speed from the equation
			mountingSpeed = hspeed.length()##sets how fast you'll move on the rail
			
			


## Makes the fish unmount the rail and return to normal
func unmount():
	isBeingUsed = false
	fish.isRailGrinding = false
	fish.reparent(get_tree().get_current_scene()) #make the fish a child of the level
	fish.linear_velocity = Vector3(0.001,0.001,0.001)
	

## Sets where the fish is going to be relative to the rail
func lock_fish_in_place():
	fish.position = Vector3(0,0.7,0)
	fish.rotation_degrees = Vector3(0,-45,0)
	fish.linear_velocity = Vector3(0.001,0.001,0.001)
	fish.angular_velocity = Vector3(0.001,0.001,0.001)


func debug_stuff():
	$debugLabel.text = str("Prog: ", snapped(progress_ratio*100, 0.01), "%", 
						"\nCooldown: ", mountingCooldown, 
						"\nDirection: ", direction,
						"\nSpeed: ", mountingSpeed)
	$debugVisual.material_override.albedo_color = Color("ff0000")
	if isBeingUsed:
		$debugVisual.material_override.albedo_color = Color("00ff00")
