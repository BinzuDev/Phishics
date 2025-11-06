extends Node

const D = 0; const C = 1; const B = 2; const A = 3      #Rank number shortcuts
const S = 4; const P = 5; const PSS = 6; const PSSS = 7


## Style Meter Variables
var scoreVisual : int = 0 ##What the UI is moving towards (so that theres a delay bcs of the animation)
var finalScore : int = 0 ##Total Style points received
var points : int = 0    ##Amount of points in the current combo
var mult : float = 0      ##Amount of multiplier in the current combo
var styleMeter : int = 0 ##Total amount of the style meter (styleScore + points*mult)
var styleScore : int = 0 ##Works like score used to, but goes down over time
var styleDecreaseRate : float = 0.1 ##what makes the style bar slowly go down
var styleRank = 0      #0    1       2       3       4       5       6        7     #extra rank so
					   #D    C       B       A       S       Ps     Pss      Psss   #the math works
var rankRequirements = [0, 100000, 250000, 500000, 900000, 1500000, 2350000, 3500000, 4000000]
						  #+100k   +150k   +250k   +400k   +600k    +850k   +1150k
var rankAnimTimer : float = 0 #animation timer for the rank movement
var idle : bool = false

## Fresh meter
var trickHistory = [] #stores your previous 10 tricks
var trickHistoryExtra = [] #stores an extra 5 tricks so you cant spam in high density areas
var freshness : int
enum FRESH {LOW, WARN, OK, HIGH}
var freshState = FRESH.OK
var freshCombo := 0
var timeSinceFreshChange := 0
@onready var freshSprites = [%FreshBonus1,%FreshBonus2,%FreshBonus3,%FreshBonus4,%FreshBonus5]

## Combo variables
var combo_dict = {} #stores all of the types of tricks you've done this combo
var comboTimer : float = 0.0 #timer that ticks down, ends combo when it reaches 0
const comboReset : int = 120 #amount that the comboTimer gets set to when the combo refreshes

## Air spin variables
var airSpinAmount : float = 0.0
var airSpinRank : int = 0
var airSpinHighestRank : int = 0
#All of the required spin amounts to rank up the air spin meter
#const ASnormalRequirements = [360*2, 360*4, 360*7, 360*11, 360*16, 360*24, 360*34, 360*55, 360*55, 360*89, 9999999*9999999]
const ASnormalRequirements = [360*3, 360*6, 360*9, 360*13, 360*18, 360*25, 360*34, 360*55, 360*55, 360*89, 9999999*9999999]
const ASnormalRankColor = ["00d8ff", "ff00e8", "00d8ff", "ff00e8", "00d8ff", "ff00e8", "00d8ff", "ff00e8", "ff00e8", "00d8ff", "00d8ff", "000000"]
const ASsurfRequirements = [360*1, 360*2, 360*3, 360*4, 360*5, 360*6, 360*7, 360*8, 360*8, 360*10, 9999999*9999999]
const ASsurfRankColor = ["f08a15", "000000", "f08a15", "000000", "f08a15", "000000", "f08a15", "000000", "000000", "f08a15", "f08a15", "000000"]
var ASrequirements = []
var ASrankColor = []

var fish #gets set automatically inside the fish script


##Make the airspin meter follow the fish
func _process(_delta):
	var cam = get_viewport().get_camera_3d()
	if fish and cam:
		var pos_3d = fish.global_position
		var pos_2d = cam.unproject_position(pos_3d)
		fish.set_jump_meter_pos(pos_2d)
		pos_2d = Vector2(round(pos_2d.x + 38.5), round(pos_2d.y -109) )
		%spinMeter.global_position = pos_2d



func _physics_process(_delta: float) -> void:
	$UI.visible = true
	
	ASrequirements = ASnormalRequirements
	ASrankColor = ASnormalRankColor
	if fish:
		if fish.surfMode:
			ASrequirements = ASsurfRequirements
			ASrankColor = ASsurfRankColor
	
	
	## Air spin
	var doAirSpin = false   #look at variable list above to see requirements
	if airSpinAmount > ASrequirements[airSpinRank]: #if the spin amount is bigger than the requirement for the current rank
		doAirSpin = true
		if airSpinRank == 7:
			airSpinRank += 1 #give an extra rank just so that the sfx is pitched up extra
		if airSpinRank == 9:
			$specialTrick2.play()
	
	
	
	
	if doAirSpin:
		var newHigh = false
		airSpinRank += 1
		
		if airSpinRank >= airSpinHighestRank:
			newHigh = true
			#clamp to 7 so you can still here the last 3 notes
			#even if its not the first time you've done it this combo
			airSpinHighestRank = clamp(airSpinRank, 0, 7)
			#if fish.surfMode:
			#	airSpinHighestRank = 0 #ALWAYS show in surf mode
		
		
		if newHigh:
			$airSpin.pitch_scale = 1 + airSpinRank*0.1
			$airSpin.play()
			airSpinUIgrow()
			if fish.surfMode:
				#if airSpinRank == 9:
				#	give_points(0, 1, true, str(8*360,"°")) #special exception bcs you skip a rank
				if airSpinRank == 10:
					give_points(5000, 5, true, "3600°")
				else:
					give_points(0, 1, true, "360°")  #str(airSpinRank*360, "°")
				
			else:
				if airSpinRank == 10:
					give_points(5000, 10, true, "MAX AIRSPIN")
					if fish.height <= 15:
						give_points(0, 15, true, "CLOSE CALL")
						comboTimer += 100
				elif airSpinRank == 9:
					give_points(500, 5, true, "AIRSPIN")
				elif airSpinRank >= 1 and airSpinRank <= 7:
					give_points(200, 1, true, "AIRSPIN")
		
	
	## Airspin UI
	if airSpinRank == 0:   #set min value to 0 on first rank
		%spinMeter.min_value = 0 
	else:                  #set min value to the max value of previous rank
		%spinMeter.min_value = ASrequirements[airSpinRank-1]
	%spinMeter.tint_under= ASrankColor[airSpinRank-1]
	%spinMeter.tint_progress = ASrankColor[airSpinRank]
	%spinMeter.max_value = ASrequirements[airSpinRank]
	%spinMeter.value = airSpinAmount
	$UI/airSpin.scale.x = move_toward($UI/airSpin.scale.x, 1.0, 0.01)
	$UI/airSpin.scale.y = move_toward($UI/airSpin.scale.y, 1.0, 0.01)
	if fish:
		if airSpinRank < airSpinHighestRank-1 or (airSpinAmount < 100 and !fish.surfMode) or (airSpinAmount == 0 and fish.surfMode):
			$UI/airSpin.modulate.a -= 0.2
		else:
			$UI/airSpin.modulate.a += 0.2
		if fish.surfMode:
			%spinRank.label_settings.font_color = "f08a15"
			%spinRank.label_settings.outline_color = "000000"
		else:
			%spinRank.label_settings.font_color = "ff00ff"
			%spinRank.label_settings.outline_color = "00ffff"
		
	else:
		$UI/airSpin.modulate.a = 0 #hide if no fish
	
	$UI/airSpin.modulate.a = clamp($UI/airSpin.modulate.a, 0, 1)
	if airSpinRank < 8:
		%spinRank.text = str(airSpinRank+1)
	else:
		%spinRank.text = str(airSpinRank)
	
	
	## COMBO METER ##
	comboTimer -= 1   #How fast the combo timer ticks down
	
	if comboTimer <= 0:
		end_combo()  ##add pts x mult to score then reset the combo
	
	## Combo UI
	%points.text = str(points)
	%mult.text = format_decimal(mult)
	%comboBar.custom_minimum_size.x = comboTimer * 8
	if mult == 0:
		$UI/comboText.visible = false
		$UI/comboScore.visible = false
		%comboBar.visible = false
	else:
		$UI/comboText.visible = true
		$UI/comboScore.visible = true
		%comboBar.visible = true
	$UI/comboScore.scale.x = move_toward($UI/comboScore.scale.x, 1.0, 0.01)
	$UI/comboScore.scale.y = move_toward($UI/comboScore.scale.y, 1.0, 0.01)
	$UI/comboText.scale.x = move_toward($UI/comboText.scale.x, 1.0, 0.02)
	$UI/comboText.scale.y = move_toward($UI/comboText.scale.y, 1.0, 0.02)
	
	
	## Calclulate Style Meter   
	if styleRank <= A:
		styleDecreaseRate = 0.1   #clamp(styleDecreaseRate, 0.15, 0.5) 
	elif styleRank <= PSS:
		styleDecreaseRate = 0.08
	if styleRank == PSSS:
		styleDecreaseRate = 0.06
	if styleMeter >= rankRequirements[-1]: 
		styleDecreaseRate = 1 #so you can't keep PSSS maxed out forever
	if airSpinRank == 10: 
		styleDecreaseRate = 0.02 #so you dont lose your rank in really big falls
	if freshState == FRESH.LOW:
		styleDecreaseRate = 0.16
	if idle: #lose rank quickly when you stop moving EXCEPT IF YOU TIPLANDED OR HOOKING (set in fish.gd)
		styleDecreaseRate = 0.5 
	
	
	
	
	update_style_meter()
	
	## Rank up
	if styleMeter >= rankRequirements[styleRank+1] and styleRank < PSSS:
		if styleRank < A:
			ScoreManager.play_trick_sfx("rare")
			ScoreManager.change_rank(1, 0.25)
		elif styleRank < PSS:
			ScoreManager.play_trick_sfx("legendary")
			ScoreManager.change_rank(1, 0.5)
		else:
			ScoreManager.play_trick_sfx("legendary")
			ScoreManager.change_rank(1, 1) #max out the style meter when you reach PSSS
		get_tree().get_first_node_in_group("player").set_fov(78)
	
	
	## Rank down
	if styleMeter < rankRequirements[styleRank] and styleRank > D:
		print("rank down", "styleMeter: ", styleMeter, " StyleRank: ", styleRank, " requirement: ", rankRequirements[styleRank] )
		ScoreManager.change_rank(-1, 0.5)
	
	
	
	
	## Score and style meter UI
	var scoreBefore = int(%score.text)
	var scoreUI = lerp(float(%score.text), float(scoreVisual), 0.109) #make the score increase 10% at a time (the extra 09 just makes it look more random)
	scoreUI = int( move_toward(scoreUI, scoreVisual, 1) ) #move by at least 1 in case the difference is less than 1
	%score.text = str("%010d" % clamp(scoreUI, 0, 9999999999)) #Display score
	var scoreDiff = scoreUI-scoreBefore
	var everyXframe = 1
	if scoreDiff <= 50:
		everyXframe = 5
	elif scoreDiff <= 500:
		everyXframe = 4
	elif scoreDiff <= 5000:
		everyXframe = 3
	elif scoreDiff <= 50000:
		everyXframe = 2
	
	if scoreBefore != scoreUI and GameManager.gameTimer % everyXframe == 0 and scoreBefore != 9999999999:
		#print(scoreDiff, " (",everyXframe, ")")
		$tick.play()
	var diff = rankRequirements[styleRank+1] - rankRequirements[styleRank]
	var progress = float(styleMeter) - rankRequirements[styleRank]
	%StyleBarProgress.scale.x = progress / diff * 208
	%StyleBarProgressBG.scale.x = progress / diff * 208
	
	
	## rank UI 3D animation
	%rankBG.frame = %rank.frame
	%scoreBG.text = %score.text
	rankAnimTimer += 0.05  
	var strenght : int = 2
	if styleRank == PSSS: #makes effect even strong on final rank
		strenght = 4               #rotates faster at higher ranks
	%rankBG.position.x = -257 + sin(rankAnimTimer*styleRank*-1)*strenght
	%rankBG.position.y = 139 + cos(rankAnimTimer*styleRank*-1)*strenght
	%rank.position.x = -259 + cos(rankAnimTimer*styleRank)*strenght
	%rank.position.y = 142 + sin(rankAnimTimer*styleRank)*strenght
	
	#Instant rank up for testing
	if Input.is_action_just_pressed("debug_button"):
		give_points(100000000, 1, true, "debug")
	
	
	##Freshness
	%FreshBonus1.frame = wrap(%FreshBonus1.frame+1, 0, 30)
	%FreshBonus2.frame = wrap(%FreshBonus2.frame+1, 0, 60)
	%FreshBonus3.frame = wrap(%FreshBonus3.frame+1, 0, 30)
	%FreshBonus4.frame = wrap(%FreshBonus4.frame+1, 0, 30)
	%FreshBonus5.frame = wrap(%FreshBonus5.frame+1, 0, 48)
	timeSinceFreshChange += 1
	if timeSinceFreshChange == 500: #so it doesnt last long
		if freshState == FRESH.LOW or freshState == FRESH.WARN:
			trickHistory = []
			trickHistoryExtra = []
			freshState = FRESH.OK
			%freshAnims.play("RESET")
			print("RESET FRESHNESS")
	if timeSinceFreshChange >= 720:
		if freshState == FRESH.OK:
			trickHistory = []
			trickHistoryExtra = []
			%freshAnims.play("RESET")
			print("RESET FRESHNESS")
			timeSinceFreshChange = 0
	
	
	
	
	
	#DEBUG_INFO
	%debugLabel.text = str(
	"styleScore: ", styleScore, "\n",
	"combo: ", points*mult, "\n",
	"styleMeter: ", styleMeter, "\n",
	"prev rank: ", rankRequirements[styleRank], "\n",
	"next rank: ", rankRequirements[styleRank+1], "\n",
	"styleDecreaseRate: ", styleDecreaseRate, "%","\n",
	"timeSinceFreshChange: ", timeSinceFreshChange,"\n",
	"current rank is: ", styleRank,"\n",
	"airSpinAmount: ", airSpinAmount, "\n",
	"airSpinRank: ", airSpinRank, "\n",
	"airSpinHighestRank: ", airSpinHighestRank, "\n",
	"final score: ", finalScore
	)
	%freshDebugLabel.text = str(array_to_str(trickHistoryExtra),
							array_to_str(trickHistory), 
							"freshness: ", freshness, "\nfresh state: ", freshState)
	
	




######################
## Custom Functions ##
######################

##Give the player points, mult, and chose if you want to reset the combo timer
func give_points(addPoints: int, addMult: float, resetTimer: bool = false, trickName: String = "", rarity: String = ""):
	
	if process_mode == PROCESS_MODE_DISABLED:
		return #disable scoring system when the ui is hidden
	
	trickName = trickName.replace(" ", " ") ##WARNING REPLACES EVERY SPACE WITH A NON-BRAKING SPACE
	
	
				 #let the airspin reset timer but ONLY when theres no combo yet
	if resetTimer or (trickName == "AIRSPIN" and mult == addMult):
		if freshState != FRESH.LOW: #spam penality
			comboTimer = max(comboReset, comboTimer) #dont crop timer if bigger than maximum (ex: post dunking)
		if freshState == FRESH.WARN:
			comboTimer *= 0.8 #small penalty when you're in spam warning, comboReset time is 20% shorter
		#if you want to give a timer bonus, manually set comboTimer to a high value right before give_points()
	
	points += addPoints
	mult += addMult
	
	if resetTimer or addMult > 0:
		$UI/comboScore.scale = Vector2(1.2, 1.2) #make the PTSxMULT ui grow
	
	## Create/increase the trick
	if trickName == "" or (addPoints == 0 and addMult == 0) : #dont add it to the list if the trick has no name
		pass
	else:
		if !combo_dict.has(trickName): #create the trick if it doesnt exist
			combo_dict[trickName] = [addPoints, addMult]
			if rarity == "uncommon": #play sfx only the first time it gets added
				play_trick_sfx("uncommon")
			$UI/comboText.scale = Vector2(1.15, 1.15) #make combo list grow when something is added for the first time
		else:   #if it exists, add pts and mult
			combo_dict[trickName][0] += addPoints
			combo_dict[trickName][1] += addMult
	
	## Add trick to combo list on the UI
	%comboText.clear()
	for trick in combo_dict.keys(): #for every trick in the list of tricks done this combo
		if %comboText.get_total_character_count() > 0:
			%comboText.append_text(" + ") #add a + unless its the first one
		%comboText.append_text(str(trick, ": ")) #add trick name
		
		if combo_dict[trick][0] != 0: #show points unless its 0
			%comboText.append_text(str(combo_dict[trick][0]))
		if combo_dict[trick][1] != 0: #show mult unless its 0
			%comboText.append_text(str("x", format_decimal(combo_dict[trick][1]) ))
		
	%wallShrinker.scale = Vector2(1, 1)
	%comboText.custom_minimum_size.x = 1600.0
	if %comboText.get_total_character_count() >= 320:
		%wallShrinker.scale = Vector2(0.75, 0.75)
		%comboText.custom_minimum_size.x = 2150.0
	
	


func end_combo():
	if mult >= 5:
		$comboEnd.play() #play sfx only once
	if mult >= 1 and freshState != FRESH.LOW:
		combo_end_animation()
		set_label_settings(points * mult)
	
	finalScore += points * mult
	styleScore += points * mult
	points = 0
	mult = 0
	airSpinHighestRank = 0
	%comboText.text = ""
	combo_dict.clear()
	

func combo_end_animation():
	%comboEndValue.set_position($UI/comboScore.get_screen_position()) 
	%comboEndValue.position.y -= 70
	%comboEndValue.visible = true
	%comboEndRotation.rotation = 0
	%comboEndRotation.skew = 0
	%comboEndText.text = format_big_number(str(int(points * mult)))
	%comboEndValue.scale = Vector2(0,0)
	var tween = get_tree().create_tween()
	tween.tween_property(%comboEndValue, "scale", Vector2(1.2, 1.2), 1.5) \
		.set_trans(Tween.TRANS_ELASTIC) \
		.set_ease(Tween.EASE_OUT)
	var tween2 = get_tree().create_tween()
	tween2.tween_interval(0.75)
	tween2.tween_property(%comboEndValue, "position:x", %comboTargetPos.get_screen_position().x, 0.9) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	tween2.parallel().tween_property(%comboEndValue, "position:y", %comboTargetPos.get_screen_position().y, 0.9) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_IN)
	tween2.parallel().tween_property(%comboEndRotation, "rotation", deg_to_rad(15), 0.9) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_IN)
	tween2.parallel().tween_property(%comboEndRotation, "skew", deg_to_rad(-15), 0.9) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_IN)
	tween2.tween_callback(combo_end_anim_over)



func combo_end_anim_over():
	%comboEndValue.visible = false
	if finalScore-scoreVisual >= 10000: #so its not annoying or super small combos
		$money.play()
	scoreVisual = finalScore
	




func update_style_meter():
	#Reduce the styleScore over time, speed of reduction depends on combo size and styleDecreaseRate
	styleScore -= (styleScore + points*mult) * styleDecreaseRate * 0.01
	#combine styleScore and the current combo to create the final styleMeter value  
	styleMeter = styleScore + points*mult
	styleMeter = clamp(styleMeter, 0, rankRequirements[-1])


func update_freshness(object):
	trickHistory.append(object)
	
	#remove the last one when more then 10
	if trickHistory.size() > 10:
		trickHistoryExtra.append(trickHistory[0])
		trickHistory.remove_at(0)  
		if trickHistoryExtra.size() > 5:
			trickHistoryExtra.remove_at(0)  
	
	freshness = 0
	
	#Only check the 4 most recent tricks (or all of them if theres less than 4)
	for i in range(-min(4, trickHistory.size()), 0):
		#print("trick at index ", i, " is: ", trickHistory[i].name)
		#Find how often the most common on shows up in the full list
		freshness = max(freshness, trickHistory.count(trickHistory[i])+trickHistoryExtra.count(trickHistory[i]) )
	
	## When all 10 tricks are unique
	if trickHistory.size() == 10:
		var mostCommon = 0
		for value in trickHistory:
			mostCommon = max(mostCommon, trickHistory.count(value))
		if mostCommon == 1:
			$specialTrick1.play()
			give_points(10000, 5, true, "FRESH BONUS")
			%freshAnims.play("freshBonus")
			for sprite in freshSprites:
				sprite.visible = false
			freshSprites[freshCombo%5].visible = true
			freshCombo += 1
			trickHistory = []
			trickHistoryExtra = []
	
	## UI
	
	timeSinceFreshChange = 0
	
	if trickHistory.size() >= 4:
		if freshness >= 6 and freshState != FRESH.LOW:
			$lowFreshness.play()
			%freshAnims.play("spam_penalty")
			freshState = FRESH.LOW
		if freshness >= 4 and freshness <= 5 and freshState != FRESH.WARN:
			%freshAnims.play("spam_warn")
			freshState = FRESH.WARN
		if freshness <= 3:
			freshState = FRESH.OK
			if %freshAnims.current_animation != "freshBonus":
				%freshAnims.play("RESET")
	
	

func array_to_str(array : Array):
	var text := "["
	for value in array:
		if text != "[":
			text += ", "
		text += str(value.name)
	text += "]\n"
	return text



##meterPercentage decides where the meter start from on the next rank, on a scale of 0.0 to 1.0
func change_rank(amount: int, meterPercentage: float):
	styleRank += amount
	styleRank = clamp(styleRank, 0, 7)
	%rank.frame = 7-styleRank #set image
	%rankBG.frame = 7-styleRank
	var middle = (rankRequirements[styleRank+1]-rankRequirements[styleRank])*meterPercentage + rankRequirements[styleRank]
	styleScore = middle - (points*mult)
	
	update_style_meter()
	
	
	## Ranking up
	if amount > 0: 
		if styleRank < PSSS:
			%rankAnim.play("rank_up")
		else:
			%rankAnim.play("rank_up_PSSS")
		
		if styleRank == C:
			MusicManager.play_track(1)
		if styleRank == A:
			MusicManager.play_track(2)
		if styleRank == P:
			MusicManager.play_track(3)
		if styleRank == PSSS:
			MusicManager.play_track(4)
	
	## Ranking down
	if amount < 0:
		%rankAnim.play("rank_down")
		
		if styleRank == D:
			MusicManager.stop_track(1)
		if styleRank == B:
			MusicManager.stop_track(2)
		if styleRank == S:
			MusicManager.stop_track(3)
		if styleRank == PSS:
			MusicManager.stop_track(4)
	
	
	## Rank Voice Lines
	var rankSFX = [$damp, $coastal, $buoyant, $aquatic, $splashing, $phishics, $phishicss, $phishicsss]
	if amount < 0 and styleRank == D:
		$damp.play()
	if amount > 0 and AudioServer.get_bus_peak_volume_left_db(3,0) < -30: 
		rankSFX[styleRank].play()
	if styleRank == PSSS: #play PHISHICSSS no matter what
		$phishics.stop()
		$phishicss.stop()
		$phishicsss.play()
		

##Play a random trick sound, either "legendary", "rare" or "uncommon".
##It will also automatically NOT play any sounds if another sound of 
##equal or lower rarity is currently playing.
func play_trick_sfx(type: String):
	if !$legendary.playing:     #dont play any trick if any legendary is playing
		if type == "legendary":
			$legendary.play()
		if !$rare.playing:     #dont play any rare or uncommon if a rare is playing
			if type == "rare":
				$rare.play()
			if type == "uncommon" and !$uncommon.playing: 
				$uncommon.play()      #dont play uncommon is uncommon is playing
				

func airSpinUIgrow():
	$UI/airSpin.scale += Vector2(0.12, 0.12)

func reset_airspin(): #also used by boost ring
	airSpinAmount = 0
	airSpinRank = 0
	

func reset_everything():
	reset_airspin()
	points = 0
	mult = 0
	comboTimer = -1
	styleRank = 0
	styleMeter = 0
	styleScore = 0
	finalScore = 0
	scoreVisual = 0
	freshness = 0
	trickHistory = []
	trickHistoryExtra = []
	%rank.frame = 7
	%rankBG.frame = 7
	airSpinHighestRank = 0
	%comboText.text = ""
	%score.text = str("%010d" % 0)
	combo_dict.clear()
	%freshAnims.play("RESET")
	
	

## Used to add spaces between every 3rd digit of a big number (except if its just 4 digits)
## ex: 1234567890 -> 1 234 567 890
func format_big_number(value:String):
	var length = value.length()
	if length <= 4:
		return value
	
	while length > 3:
		length -= 3
		value = value.insert(length, " ")
	
	return value


## Used so whole decimal numbers shown on UI are shown like "5" instead of "5.0"
func format_decimal(value):
	if int(value) == value:
		return str(int(value))
	else:
		return str(value)

func hide():
	$UI.visible = false
	process_mode = Node.PROCESS_MODE_DISABLED

func show():
	process_mode = Node.PROCESS_MODE_INHERIT
	

func set_label_settings(value : int):
	%comboEndText.label_settings.font_color = Color("ffffff")
	%comboEndText.label_settings.outline_color = Color("000000")
	%comboEndText.label_settings.set_stacked_outline_size(0, 0)
	%comboEndText.label_settings.set_stacked_outline_size(1, 0)
	%comboEndText.label_settings.set_stacked_outline_size(2, 0)
	if value > 100000: #100k
		%comboEndText.label_settings.font_color = Color("00ffff")
	if value > 1000000: #1M
		%comboEndText.label_settings.font_color = Color("ff00ff")
		%comboEndText.label_settings.outline_color = Color("ffffff")
	if value > 10000000: #10M
		%comboEndText.label_settings.font_color = Color("00ffff")
		%comboEndText.label_settings.outline_color = Color("ff00ff")
		%comboEndText.label_settings.set_stacked_outline_size(0, 25)
		%comboEndText.label_settings.set_stacked_outline_color(0, "00ffff") 
	if value > 1000000000: #1B >:3c no one will ever know
		%comboEndText.label_settings.font_color = Color("00ffff")
		%comboEndText.label_settings.outline_color = Color("ff69ff") 
		%comboEndText.label_settings.set_stacked_outline_size(0, 25)
		%comboEndText.label_settings.set_stacked_outline_color(0, Color("ffffff"))
		%comboEndText.label_settings.set_stacked_outline_size(1, 25)
		%comboEndText.label_settings.set_stacked_outline_color(1, Color("ff69ff"))
		%comboEndText.label_settings.set_stacked_outline_size(2, 25)
		%comboEndText.label_settings.set_stacked_outline_color(2, Color("00ffff")) 
