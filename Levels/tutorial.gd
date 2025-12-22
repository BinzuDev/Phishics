extends Level

var waitingForPlayerInput : bool = false

func _ready():
	super()
	$reticle.visible = false
	$reticle/reticleAnimation.play("preset_reticle")
	MenuManager.tutorialTrickList = 0
	

var keyFrame : int = 0
var timer : int = 0
var hasEnteredTricksArea : bool = false

var waitingForReticle : bool = false

##So JFG can remark on the player not moving while reading her dialogue
var totalFishMovement : float = 0

var canSkipTutorial : bool = true


func _physics_process(_delta): 
	if waitingForPlayerInput: #wait until the player touches a direction
		if get_tree().get_first_node_in_group("player").get_input_axis() != Vector2.ZERO:
			event1end()
	
	## Key spamming visuals
	keyFrame = (keyFrame + 1) % 12
	if  keyFrame < 6 or !%spammingKeys.visible:
		$Control/keys.scale = Vector2(1,1)
		%spammingKeys.frame = 0
	else:
		$Control/keys.scale = Vector2(0.95,0.95)
		%spammingKeys.frame = 1
	
	##Fake reticle
	$reticle/rotate.rotation_degrees += 3
	timer += 1
	var newScale = sin(timer*0.157) * 0.15 + 1
	$reticle/rotate.scale = Vector2(newScale, newScale)
	$reticle.position = get_viewport().get_camera_3d().unproject_position(%RETICLETARGET.global_transform.origin)
	if waitingForReticle:
		if DialogueManager.chara > 96:
			$reticle.visible = true
			$reticle/reticleAnimation.play("reticle_appear1")
			$reticle/sfx.play()
			waitingForReticle = false
	
	##Slowmo area
	if %slowmo.has_overlapping_bodies():
		Engine.time_scale = clamp(Engine.time_scale-0.03 , 0.2, 1)
		AudioServer.get_bus_effect(4,0).pitch_scale = Engine.time_scale #music slow down
		print(Engine.time_scale)
		if %fish.homing:
			%fish.homingLookDown = true
			%diveCamCollision.disabled = true
			%slowmoCollision.disabled = true
	elif hasEnteredTricksArea == false: #otherwise it breaks hoop slowmo
		Engine.time_scale = 1
		AudioServer.get_bus_effect(4,0).pitch_scale = 1
	
	## Idling easter egg
	if hasEnteredTricksArea:
		totalFishMovement += %fish.linear_velocity.length()
		#print(totalFishMovement)
	
	## Tutorial skip:
	if canSkipTutorial and hasEnteredTricksArea:
		var combo = ScoreManager.points * ScoreManager.mult
		if combo > 5000000: #5 million
			$jfg_ignoring_easteregg/waiting.visible = false
			$Control/esc.visible = false
			MenuManager.tutorialTrickList = 0
			$tutorialSkipping.position.y = 0
			canSkipTutorial = false
			printerr("TIME LEFT: ", $jfg_ignoring_easteregg/Timer.time_left)
		
	
	
	if MenuManager.tutorialTrickList == 2:
		$tutorialStyle3.position.y = 0
	


func tutorialEvent1(): #once textbox 1 is finished
	%fish.canMove = true
	waitingForPlayerInput = true
	%slowKeypress.modulate.a = 1.25
	%spammingKeys.modulate.a = 1.25
	$Control/esc.modulate.a = 1.25
	%slowKeypress.visible = true

func event1end():
	waitingForPlayerInput = false
	await get_tree().create_timer(4.5).timeout #wait 5 seconds
	$tutorialSpamSlow.position.y = 0     #make the too slow dialogue run
	$tutorialSpamFast.position.y = -50


func tutorialEvent2():
	$tutorialSpamSlow.set_collision_mask_value(2, false) #stop the too slow dialogue from running

func tutorialEvent3():
	%slowKeypress.visible = false
	%spammingKeys.visible = true

func tutorialEvent4():
	%slowKeypress.visible = false
	%spammingKeys.visible = false

func tutorialEvent5():
	waitingForReticle = true

func tutorialEvent6():
	waitingForReticle = false
	$reticle.visible = false

func tutorialEvent7(): #start the tricks tutorial
	$tutorialStyle.position.y = 0
	hasEnteredTricksArea = true
	$jfg_ignoring_easteregg/Timer.start()
	print("started timer")
	

func _on_easter_egg_timer_timeout():
	canSkipTutorial = false
	for i in range(37):
		$jfg_ignoring_easteregg/waiting.visible_characters+=1
		await get_tree().create_timer(0.1).timeout
	

func cancel_waiting_joke():
	print("cancel joke")
	$jfg_ignoring_easteregg/waiting.visible = false

func idle_easter_egg():
	print("idle easter egg")
	if totalFishMovement < 3000:
		$idle_easteregg.position.y = 0
	else:
		$tutorialStyle2.position.y = 0

func idle_easter_egg_end():
	$tutorialStyle2.position.y = 0


func show_esc(value: bool):
	$Control/esc.visible = value
	

func tutorialEvent7point5():
	$Control/esc.visible = false
	DialogueManager.continue_dialogue()
	#print("7.5 IS RUNNING")

func tutorialEvent8(): #check how many worms
	var worm = ScoreManager.counterValue
	if worm == 0 and ScoreManager.finalScore < 100000:
		$wormNone.position.y = 0
	elif worm == 0 and ScoreManager.finalScore >= 100000:
		$wormNoneHighscore.position.y = 0
	elif worm == 1:
		$wormSingle.position.y = 0
	elif worm >= 2 and worm <= 9:
		$"worm2-9".position.y = 0
	elif worm >= 10 and worm <= 19:
		$"worm10-19".position.y = 0
	elif worm >= 20:
		$worm20.position.y = 0

func tutorialEvent9(): 
	pass
