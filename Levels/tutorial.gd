extends Level

var waitingForPlayerInput : bool = false

func _ready():
	super()
	$reticle.visible = false
	$reticle/reticleAnimation.play("preset_reticle")
	

var keyFrame : int = 0
var timer : int = 0

var waitingForReticle : bool = false

func tutorialEvent1(): #once textbox 1 is finished
	$fish.canMove = true
	waitingForPlayerInput = true
	%slowKeypress.modulate.a = 1.25
	%spammingKeys.modulate.a = 1.25
	%slowKeypress.visible = true

func _process(_delta): 
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
	$reticle.position = get_viewport().get_camera_3d().unproject_position($enemyGroup/RETICLETARGET.global_transform.origin)
	if waitingForReticle:
		if DialogueManager.chara > 76:
			$reticle.visible = true
			$reticle/reticleAnimation.play("reticle_appear1")
			$reticle/sfx.play()
			waitingForReticle = false
	
	##Slowmo area
	if $slowmo.has_overlapping_bodies():
		Engine.time_scale = clamp(Engine.time_scale-0.03 , 0.2, 1)
		AudioServer.get_bus_effect(4,0).pitch_scale = Engine.time_scale #music slow down
		print(Engine.time_scale)
		if $fish.homing:
			$fish.homingLookDown = true
			$diveLookDown/CollisionShape3D.disabled = true
			$slowmo/CollisionShape3D.disabled = true
	else:
		Engine.time_scale = 1
		AudioServer.get_bus_effect(4,0).pitch_scale = 1
	
	

func event1end():
	waitingForPlayerInput = false
	await get_tree().create_timer(5).timeout #wait 5 seconds
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
