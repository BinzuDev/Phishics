extends Node

@export_enum("off", "record", "replay") var recordingMode: String = "off"

##If left empty, the demo's file name will be the current time and date. 
##You dont have to add the path or extension, just the file name.
##WARNING: if you start the game a second time and don't change the file name,
##the file WILL be overwritten!
@export var recordingFile : String = ""
@export_file("*.json") var replayFile : String = ""
#how often the position gets fixed, 1 is maximum quality, aka every frame
@export var replayAccuracy : int = 20

var currentFile
var currentFrame

#Because taunting pauses the game, its not recording the moment you press
#the fish button, so to fix this bug I use this variable instead.
#Its controlled by the fish script directly
var fishPressed := false 

func _ready() -> void:
	currentFrame = 0
	if recordingMode == "record":
		var fileName
		if recordingFile == "":
			var date = Time.get_date_string_from_system()
			var time = Time.get_time_string_from_system()
			fileName = str("res://Recordings/", date, "_", time, ".json")
			fileName = fileName.replace(":", "-")
			fileName[3] = ":"
		else:
			fileName =  str("res://Recordings/", recordingFile, ".json")
		print("filename: ", fileName)
		currentFile = FileAccess.open(fileName, FileAccess.WRITE)
	if recordingMode == "replay":                    
		currentFile = FileAccess.open(replayFile, FileAccess.READ)
		print("replaying file: ", replayFile)


func _process(_delta):
	#if Input.is_action_just_pressed("record"):
	#	recordingMode = "record"
	#	recordFile = FileAccess.open("res://recordings/recording1.json", FileAccess.WRITE)
	if recordingMode == "record":
		#$Control/ui_rec.visible = true
		do_record()
	if recordingMode == "replay":
		#$Control/ui_play.visible = true
		do_replay()



				 # 0      1      2      3      4      5      6       7         8         9        10
				 # UP,  DOWN,  LEFT,  RIGHT,  JUMP,  DIVE, TAUNT  position   angle    velocity  ang_vel
var save_data = [false, false, false, false, false, false, false, Vector3(),Vector3(),Vector3(),Vector3()]

func do_record():
	var fish = get_parent()
	save_data = [
		Input.is_action_pressed("forward"), Input.is_action_pressed("back"),
		Input.is_action_pressed("left"), Input.is_action_pressed("right"),
		Input.is_action_pressed("jump"),  Input.is_action_pressed("dive"),
		fishPressed, fish.global_position, fish.global_rotation,
		fish.linear_velocity, fish.angular_velocity]
	
	fishPressed = false
	
	var jstr = JSON.stringify(save_data)
	
	currentFile.store_string(jstr)
	currentFile.store_string("\n")
	


 # 0    1     2     3      4     5     6  
 #UP, DOWN, LEFT, RIGHT, JUMP, DIVE, TAUNT
func do_replay():
	currentFrame += 1
	if FileAccess.file_exists(replayFile) == true:
		
		#print(gameTimer, " H: ", hspeed, " V: ", vspeed)
		var current_line = JSON.parse_string(currentFile.get_line())
		
		if currentFile.eof_reached():
			recordingMode = ""
			print("REPLAY OVER")
			Input.action_release("forward")
			Input.action_release("back")
			Input.action_release("left")
			Input.action_release("right")
			Input.action_release("jump")
			Input.action_release("dive")
			Input.action_release("FIsh")
		else:
			var setInputs = current_line
			var fish = get_parent()
			print(currentFrame, " current pos:", fish.global_position, " recording pos: ", setInputs[7] )
			
			if currentFrame % replayAccuracy == 0:
				#print("FORCE SET POSITION")
				fish.global_position = string_to_vector3(setInputs[7])
				fish.global_rotation = string_to_vector3(setInputs[8])
				fish.linear_velocity = string_to_vector3(setInputs[9])
				fish.angular_velocity = string_to_vector3(setInputs[10])
				
			
			if setInputs[0]:
				Input.action_press("forward")
			else:
				Input.action_release("forward")
			if setInputs[1]:
				Input.action_press("back")
			else:
				Input.action_release("back")
			if setInputs[2]:
				Input.action_press("left")
			else:
				Input.action_release("left")
			if setInputs[3]:
				Input.action_press("right")
			else:
				Input.action_release("right")
			if setInputs[4]:
				Input.action_press("jump")
			else:
				Input.action_release("jump")
			if setInputs[5]:
				Input.action_press("dive")
			else:
				Input.action_release("dive")
			if setInputs[6]:
				Input.action_press("FIsh")
			else:
				Input.action_release("FIsh")



static func string_to_vector3(string := "") -> Vector3:
	if string:
		var new_string: String = string
		new_string = new_string.erase(0, 1)
		new_string = new_string.erase(new_string.length() - 1, 1)
		var array: Array = new_string.split(", ")
		return Vector3(float(array[0]), float(array[1]),  float(array[2]))
		
	return Vector3.ZERO
