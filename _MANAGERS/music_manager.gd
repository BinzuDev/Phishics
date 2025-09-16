extends Node

@onready var currentSong : AdaptiveMusicTrack = $AdaptiveMusicTrack



##Start/Stop queue. keeps track of which clip should start or stop on the next bar.
##FALSE means that the clip should stop, TRUE means that it should start
var SSqueue : Array = []
##List of which track are currently fading in or fading out, only updates every bar
var StartStop : Array = []

##Contains a list of all tracks, each containing a list of all clips in said tracks. 
##If you want to know which track a clip is part of, use currentSong.clipGrouping[x]. with x being the index of the clip
var trackList : Array = [] 

##Everytime the song loops, this variable flips
##This is what makes the tracks alternate between the default clips and the extra clips
var playingAltTracks : bool = false

var time : float = 0.0 #Keeps tracks of precisely where we are in the song
var barProgress : int = 0 #How far along we are in the current bar, in seconds*100


func _ready():
	reset_music()
	print(SSqueue)
	

func reset_music():
	##Instantiate the wait queue and start track 0
	SSqueue.resize(currentSong.stream.stream_count)
	StartStop.resize(currentSong.stream.stream_count)
	for i in SSqueue.size():
		SSqueue[i] = false
		StartStop[i] = false
	SSqueue[0] = true
	StartStop[0] = true
	##Instantiate the 2D list of tracks and clips
	trackList = []
	for i in currentSong.trackCount: #create the correct amount of track
		trackList.append([])
	for clipIndex in currentSong.clipGrouping.size():
		var track = currentSong.clipGrouping[clipIndex]
		trackList[track].append(clipIndex)
	print(trackList)
	print(currentSong.clipGrouping)
	##Restart all tracks and mute everything except track 0
	$AdaptiveMusicTrack.stop()
	for i in currentSong.stream.stream_count:
		currentSong.stream.set_sync_stream_volume(i, linear_to_db(0))
	currentSong.stream.set_sync_stream_volume(0, linear_to_db(1))
	$AdaptiveMusicTrack.play()



func stop_track(trackIndex : int):
	if $musicDebug.visible:
		printerr("STOPPING TRACK #", trackIndex, " NEXT BAR")
	SSqueue[trackIndex] = false
	

func play_track(trackIndex : int):
	if $musicDebug.visible:
		print("STARTING TRACK #", trackIndex, " NEXT BAR")
	SSqueue[trackIndex] = true
	


func _physics_process(_delta):
	time = currentSong.get_playback_position() + AudioServer.get_time_since_last_mix() + (AudioServer.get_output_latency()*2)
	#if the current time is LOWER than it was last frame, 
	#then it must be because we're on a new bar now.
	var newBarProgress = int(time*100) % int(currentSong.get_bar_length()*100)
	
	if newBarProgress < barProgress:
		_on_bar_end_timeout()
	
	barProgress = newBarProgress
	



func _process(_delta):
	
	##Fade in/out
	for i in StartStop.size():
		var vol = db_to_linear(currentSong.stream.get_sync_stream_volume(i))
		var fadeSpd = 1.0
		if i == 1: #add a fade JUST for the bass
			fadeSpd = 0.05
		if StartStop[i] == true:
			vol = move_toward(vol, 1, fadeSpd) #fade in
			currentSong.stream.set_sync_stream_volume(i, linear_to_db(vol))
		else:
			vol = move_toward(vol, 0, fadeSpd) #fade out
			currentSong.stream.set_sync_stream_volume(i, linear_to_db(vol))
	
	
	##Debug
	var musicDebug = str("Time is: ", time, "\n")
	for i in trackList.size():
		musicDebug += str("    (track #", i, "):\n")
		for j in trackList[i].size():
			musicDebug += str("Clip #",trackList[i][j], " db: ", snapped(currentSong.stream.get_sync_stream_volume(trackList[i][j]), 0.01) )
			if SSqueue[trackList[i][j]] == true and StartStop[trackList[i][j]] == false:
				musicDebug += str(" (queued to start)")
			if SSqueue[trackList[i][j]] == false and StartStop[trackList[i][j]] == true:
				musicDebug += str(" (queued to stop)")
			musicDebug += "\n"
	$musicDebug.text = musicDebug
	


##This function runs once per bar
func _on_bar_end_timeout():
	if $musicDebug.visible:
		print("bar ended at ", time, " latency: ", AudioServer.get_output_latency())
	StartStop = SSqueue.duplicate()




##This function runs when the song loops
func _on_song_end_timeout():
	if $musicDebug.visible:
		print("SONG LOOP")
	playingAltTracks = !playingAltTracks
	
	
	for track in trackList:
		if track.size() > 1: #ignore if the track only contains 1 clip
			#if playingAltTracks:
				#if StartStop[track[0]] == true:
					#currentSong.stream.set_sync_stream_volume(track[0], 0)
					#StartStop[track[0]] = false
					#SSqueue[track[0]] = false
			
			randomize()
			print("track: ", track[0], " start playing subtrack ", randi_range(1,track.size()-1) )
	

##Find which track a given clip belongs to
func get_track_of_clip(index:int):
	return currentSong.clipGrouping[index]



func _on_button_pressed():
	play_track(2)

func _on_button_2_pressed():
	stop_track(2)
