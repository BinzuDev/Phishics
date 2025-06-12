extends Node

const D = 0; const C = 1; const B = 2; const A = 3      #Rank number shortcuts
const S = 4; const P = 5; const PSS = 6; const PSSS = 7


## Style Meter Variables
var finalScore : int = 0     ##Total Style points received
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

## Combo variables
var combo_dict = {} #stores all of the types of tricks you've done this combo
var comboTimer : float = 0.0 #timer that ticks down, ends combo when it reaches 0
const comboReset : int = 120 #amount that the comboTimer gets set to when the combo refreshes

## Air spin variables
var airSpinAmount : float = 0.0
var airSpinRank : int = 0
var airSpinHighestRank : int = 0
#All of the required spin amounts to rank up the air spin meter
var ASrequirements = [320*2, 360*4, 360*7, 360*11, 360*16, 360*24, 360*34, 360*55, 360*55, 360*89, 9999999*9999999]
#var ASrankColor = ["ff00ff", "bb00ff", "0000ff", "0080ff", "00ffff" , "00ff40", "f2ff00", "ff9900", "ff9900", "ff0000", "ff0000", "ffffff"]
var ASrankColor = ["00d8ff", "ff00e8", "00d8ff", "ff00e8", "00d8ff", "ff00e8", "00d8ff", "ff00e8", "ff00e8", "00d8ff", "00d8ff", "000000"]

var fish #gets set automatically inside the fish script




func _physics_process(_delta: float) -> void:
	
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
		
		
		if newHigh:
			$airSpin.pitch_scale = 1 + airSpinRank*0.1
			$airSpin.play()
			airSpinUIgrow()
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
	if airSpinRank < airSpinHighestRank-1 or airSpinAmount < 100:
		$UI/airSpin.modulate.a -= 0.2
	else:
		$UI/airSpin.modulate.a += 0.2
	$UI/airSpin.modulate.a = clamp($UI/airSpin.modulate.a, 0, 1)
	
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
	if idle: #lose rank quickly when you stop moving EXCEPT IF YOU TIPLANDED (set in fish.gd)
		ScoreManager.styleDecreaseRate = 0.5 
	
	
	
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
		ScoreManager.change_rank(-1, 0.5)
	
	#Reduce the styleScore over time, speed of reduction depends on combo size and styleDecreaseRate
	styleScore -= (styleScore + points*mult) * styleDecreaseRate * 0.01
	#combine styleScore and the current combo to create the final styleMeter value  
	styleMeter = styleScore + points*mult
	styleMeter = clamp(styleMeter, 0, rankRequirements[-1])
	
	
	
	
	
	## Score and style meter UI
	%score.text = str("%010d" % clamp(finalScore, 0, 9999999999)) #Display score
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
	
	#DEBUG_INFO
	%debugLabel.text = str(
	"styleScore: ", styleScore, "\n",
	"combo: ", points*mult, "\n",
	"styleMeter: ", styleMeter, "\n",
	"prev rank: ", rankRequirements[styleRank], "\n",
	"next rank: ", rankRequirements[styleRank+1], "\n",
	"styleDecreaseRate: ", styleDecreaseRate, "%","\n",
	"airSpinAmount: ", airSpinAmount, "\n",
	"airSpinRank: ", airSpinRank, "\n",
	"airSpinHighestRank: ", airSpinHighestRank
	)





######################
## Custom Functions ##
######################

##Give the player points, mult, and chose if you want to refresh the combo timer
func give_points(addPoints: int, addMult: float, resetTimer: bool = false, trickName: String = "", rarity: String = ""):
	points += addPoints
	mult += addMult      
					  #let the airspin reset timer but ONLY when theres no combo yet
	if resetTimer or (trickName == "AIRSPIN" and mult == addMult):
		comboTimer = max(comboReset, comboTimer) #dont crop timer if bigger than maximum (ex: post dunking)
	
	if resetTimer or addMult > 0:
		$UI/comboScore.scale = Vector2(1.2, 1.2) #make the PTSxMULT ui grow
	
	## Create/increase the trick
	if trickName != "": #dont add it to the list if the trick has no name
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
			
			


func end_combo():
	finalScore += points * mult
	styleScore += points * mult
	points = 0
	mult = 0
	airSpinHighestRank = 0
	%comboText.text = ""
	combo_dict.clear()


##meterPercentage decides where the meter start from on the next rank, on a scale of 0.0 to 1.0
func change_rank(amount: int, meterPercentage: float):
	styleRank += amount
	styleRank = clamp(styleRank, 0, 7)
	%rank.frame = 7-styleRank #set image
	var middle = (rankRequirements[styleRank+1]-rankRequirements[styleRank])*meterPercentage + rankRequirements[styleRank]
	styleScore = middle - (points*mult)
	
	## Ranking up
	if amount > 0: 
		if styleRank < PSSS:
			%rankAnim.play("rank_up")
		else:
			%rankAnim.play("rank_up_PSSS")
		
		if styleRank == C:
			MusicManager.play_track(1, 1)
		if styleRank == A:
			MusicManager.play_track(2, 1)
		if styleRank == P:
			MusicManager.play_track(3, 1)
		if styleRank == PSSS:
			MusicManager.play_track(4, 1)
	
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

func reset_airspin(): # also used by boost ring
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
	%rank.frame = 7
	%rankBG.frame = 7
	

## Used so whole decimal numbers shown on UI are shown like "5" instead of "5.0"
func format_decimal(value):
	if int(value) == value:
		return str(int(value))
	else:
		return str(value)

func hide():
	$UI.visible = false

func show():
	$UI.visible = true
