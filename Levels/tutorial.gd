extends Level

var waitingForPlayerInput : bool = false

func _ready():
	super()
	


func tutorialEvent1(): #once textbox 1 is finished
	$fish.canMove = true
	waitingForPlayerInput = true
	

func _process(_delta): 
	if waitingForPlayerInput: #wait until the player touches a direction
		if get_tree().get_first_node_in_group("player").get_input_axis() != Vector2.ZERO:
			event1end()
		

func event1end():
	waitingForPlayerInput = false
	await get_tree().create_timer(5).timeout #wait 5 seconds
	$tutorialSpamSlow.position.y = 0     #make the too slow dialogue run
	$tutorialSpamFast.position.y = -50



func tutorialEvent2():
	$tutorialSpamSlow.set_collision_mask_value(2, false) #stop the too slow dialogue from running
