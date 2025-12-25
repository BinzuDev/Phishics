extends Node3D


var currentId : int = 0

var bufferredInput := "false"

var mouseHovered := false #if the mouse is over the center skin
var mousePosLastFrame : float #to get the speed of the mouse

#keeps track of the ID of the last skin in the database
var maxSkin : int = 1

func _ready():
	maxSkin = GameManager.database.skins.size()
	set_skin_carousel()


func _physics_process(delta):
	if Input.is_action_just_pressed("left"): #when left pressed
		if !$AnimationPlayer.is_playing():    #if animation not playing
			select_left()                      #select the left skin
		else:                                 #otherwise
			bufferredInput = "left"            #buffer a left input
			#dont speed up the animation if you buffer at the VERY END
			if $AnimationPlayer.current_animation_position < 0.20: 
				$AnimationPlayer.speed_scale = 2   #speed up animation
	if Input.is_action_just_pressed("right"): 
		if !$AnimationPlayer.is_playing():    #same thing but for right
			select_right()
		else:
			bufferredInput = "right"
			if $AnimationPlayer.current_animation_position < 0.20:
				$AnimationPlayer.speed_scale = 2   #speed up animation
	
	
	
	var mouseSpeed = get_viewport().get_mouse_position().x - mousePosLastFrame
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and mouseHovered:
		print(mouseSpeed)
		$Skins/skinCenter.spinSpeed = mouseSpeed * 0.003
	mousePosLastFrame = get_viewport().get_mouse_position().x
	
	
	
	#debug
	$buffer.text = str("buffered input: ", bufferredInput, "
						speed: ", $AnimationPlayer.speed_scale )
	$Skins/skinCenter/Label3D.text = str($Skins/skinCenter.rotation_degrees.y, "
										spin: ", $Skins/skinCenter.spinSpeed)



func select_left():
	$AnimationPlayer.play("move_right")
	currentId = wrap(currentId-1, 0, maxSkin)
	$Skins/skinBehind.quick_set_skin(currentId-2)

func select_right():
	$AnimationPlayer.play("move_left")
	currentId = wrap(currentId+1, 0, maxSkin)
	$Skins/skinBehind.quick_set_skin(currentId+2)


func _on_animation_finished(anim_name):
	set_skin_carousel()
	await get_tree().process_frame #wait an extra frame to fix animationPlayer bug
	if bufferredInput == "left":  
		select_left()   #if an input was buffered, select the next skin
	if bufferredInput == "right":
		select_right()
	if bufferredInput == "false": #reset the speed if you didnt buffer an input
		$AnimationPlayer.speed_scale = 1
	bufferredInput = "false"
	

## Reset the skins to their original locations
## and on the same frame, swap their textures around.
## It works because currentID was moved in select_left/right()
func set_skin_carousel():
	$Skins/skinFarLeft.position = Vector3(-4,0,-4)
	$Skins/skinLeft.position = Vector3(-2.6,0,-0.7)
	$Skins/skinCenter.position = Vector3(0,0,0)
	$Skins/skinRight.position = Vector3(2.6,0,-0.7)
	$Skins/skinFarRight.position = Vector3(4.0,0,-4.0)
	$Skins/skinBehind.position = Vector3(0,0,-8.0)
	$Skins/skinFarLeft.quick_set_skin(currentId-2)
	$Skins/skinLeft.quick_set_skin(currentId-1)
	$Skins/skinCenter.quick_set_skin(currentId)
	$Skins/skinRight.quick_set_skin(currentId+1)
	$Skins/skinFarRight.quick_set_skin(currentId+2)
	$Skins/skinCenter.rotation.y = 0
	$Skins/skinCenter.spinSpeed = $Skins/skinCenter.BASE_SPIN_SPEED
	



func _on_mouse_entered():
	mouseHovered = true
func _on_mouse_exited():
	mouseHovered = false
