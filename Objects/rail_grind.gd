@icon("res://icons/railGrind.png")
class_name railGrind
extends PathFollow3D

var isRailgrinding: bool = false #if the fish is currently using this rail
var fish: player
var path_3d: Path3D #the parent path object of railgrind
var mountingCooldown = 0 #cooldown after unmounting

func _ready():
	fish = get_tree().get_first_node_in_group("player") #get the fish
	if get_parent() is Path3D: #get the path3d parent, with a proper safety net
		path_3d = get_parent() 
	else:
		printerr("RAILGRIND OBJECT \"", name, "\" IS A CHILD OF \"", get_parent().name, "\", WHICH IS NOT A PATH3D NODE, STOPPING PROCESS.")
		process_mode = Node.PROCESS_MODE_DISABLED #the safety net in question

##TODO: You should only railgrind while surfing 👍
##TODO: when mounting, you should be placed upright, and ABOVE the rail
##TODO: starting a railgrind should add it to the freshness list 👍
##TODO: trick every frame during railgrind
##TODO: during railgrind, the fish should probably have its collisions turned off, to avoid unintended interactions and crashes
##TODO: when unmounting, you should keep your momentum
##TODO: while railgrinding, the fish should not be considered airborne

##NOTICE: using fish.trueSpeed, you can now get how fast the fish is ACTUALLY moving, use this instead of linear_speed for calculations
##fish.trueSpeed is a Vector3, so just like with with velocity, you can use fish.trueSpeed.length() to get the speed

func _process(_delta):
	#Makes the hitbox be as close as possible to the fish, while staying on the path
	if fish and path_3d:
		var target_position = path_3d.to_local(fish.global_position) #calculate where the fish is
		var closest_offset = path_3d.curve.get_closest_offset(target_position) #calculate where the hitbox should move
		self.progress = closest_offset #move hitbox
	
	#all the code that should happen while railgrinding
	if isRailgrinding:
		#unmount by jumping
		if Input.is_action_just_pressed("jump"):
			unmount()
			fish.apply_impulse(Vector3(0,20,0)) #jump off
		
		#unmount if you reach the end (unless its a closed loop)
		if (progress_ratio == 0.0 or progress_ratio == 1.0) and !path_3d.curve.closed:
			unmount() 
		
		
	
	#debug info
	debug_stuff()
	
	
	if isRailgrinding:
		mountingCooldown = 0
	else:
		mountingCooldown += 1

## When the fish touches the path
func _on_area_entered(body):
	if body is player and body.surfMode:
		if mountingCooldown > 60: #so you can't reenter a railgrind for 1s after leaving it
			mountingCooldown = 0 #in case you somehow unmount on the same frame, stops the game from crashing :sobbing:
			isRailgrinding = true
			body.reparent(self) #make the fish a child of the railgrind object
			ScoreManager.update_freshness(self) #freshness


## Makes the fish unmount the rail and return to normal
func unmount():
	isRailgrinding = false
	fish.reparent(get_tree().get_current_scene()) #make the fish a child of the level
	fish.linear_velocity = Vector3(0.001,0.001,0.001) #fixes surf naneinf glitch ##Change this when adding conservation of momentum



func debug_stuff():
	$debugLabel.text = str("Prog: ", snapped(progress_ratio*100, 0.01), "%", 
						"\nCooldown: ", mountingCooldown)
	$debugVisual.material_override.albedo_color = Color("ff0000")
	if isRailgrinding:
		$debugVisual.material_override.albedo_color = Color("00ff00")
