extends Node

@onready var currentSong : AdaptiveMusicTrack = $OST1



##Start/Stop queue. keeps track of which clip should start or stop on the next bar.
##FALSE means that the clip should stop, TRUE means that it should start
var SSqueue : Array = []
##List of which track are currently fading in or fading out, only updates every bar
var StartStop : Array = []

##Contains a list of all tracks, each containing a list of all clips in said tracks. 
##If you want to know which track a clip is part of, use currentSong.clipGrouping[x]. with x being the index of the clip
var trackList : Array = [] 

##Keeps track of the currently playing clip within each track
var currentlyPlaying : Array = []


##Everytime the song loops, this variable flips
##This is what makes the tracks alternate between the default clips and the extra clips
var playingAltTracks : bool = false

var time : float = 0.0 #Keeps tracks of precisely where we are in the song
var barProgress : int = 0 #How far along we are in the current bar, in seconds*100


func _ready():
	reset_music()
	


func reset_music():
	##Instantiate the wait queue and start track 0
	SSqueue.resize(currentSong.trackCount)
	StartStop.resize(currentSong.trackCount)
	for i in SSqueue.size():
		SSqueue[i] = false
		StartStop[i] = false
	SSqueue[0] = true
	StartStop[0] = true
	##Instantiate the 2D list of tracks and clips
	trackList = []
	currentlyPlaying = []
	for i in currentSong.trackCount: #create the correct amount of track
		trackList.append([])
		currentlyPlaying.append(i)
	for clipIndex in currentSong.clipGrouping.size():
		var track = currentSong.clipGrouping[clipIndex]
		trackList[track].append(clipIndex)
	##Restart all tracks and mute everything except track 0
	currentSong.stop()
	for i in currentSong.stream.stream_count:
		currentSong.stream.set_sync_stream_volume(i, linear_to_db(0))
	currentSong.stream.set_sync_stream_volume(0, linear_to_db(1))
	currentSong.play()
	## Debug info
	if $musicDebug.visible:
		print("tracklist: ", trackList)
		print("Track of each clip: ", currentSong.clipGrouping)
		print("Currently playing: ", currentlyPlaying)
		print("Queue: ", SSqueue)


func change_music(songName : String):
	if !get_node(songName):
		printerr("There is no song called ", songName, "!")
	else:
		if get_node(songName) is not AdaptiveMusicTrack:
			printerr(songName, " is not an AdaptiveMusicTrack node!")
		else:
			currentSong = get_node(songName)
			reset_music()
		

func stop_track(trackIndex : int):
	if $musicDebug.visible:
		printerr("STOPPING TRACK #", trackIndex, " NEXT BAR")
	SSqueue[trackIndex] = false
	

func play_track(trackIndex : int):
	if $musicDebug.visible:
		print("STARTING TRACK #", trackIndex, " NEXT BAR")
	SSqueue[trackIndex] = true
	


func _physics_process(_delta):
	#var start = Time.get_ticks_usec()
	time = currentSong.get_playback_position() + AudioServer.get_time_since_last_mix() + 0.019999 #+ (AudioServer.get_output_latency()*2)
	#if the current time is LOWER than it was last frame, 
	#then it must be because we're on a new bar now.
	var newBarProgress = int(time*100) % int(currentSong.get_bar_length()*100)
	
	
	if newBarProgress < barProgress:
		_on_bar_end_timeout()
	
	barProgress = newBarProgress
	
	#optimization check
	#var end = Time.get_ticks_usec()
	#var finalTime = (end - start)/1000.0
	#if finalTime > 6.5:
		#printerr("Frame time: ",  (end - start)/1000.0)
	#else:
		#print("Frame time: ",  (end - start)/1000.0)
	



func _process(_delta):
	
	##Debug
	var musicDebug = str("Time is: ", time, "\n")
	for i in trackList.size():
		musicDebug += str("    (track #", i, "): ")
		if SSqueue[i] == true and StartStop[i] == false:
			musicDebug += str(" (queued to start)")
		if SSqueue[i] == false and StartStop[i] == true:
			musicDebug += str(" (queued to stop)")
		musicDebug += "\n"
		for j in trackList[i].size():
			musicDebug += str("Clip #",trackList[i][j], " db: ", snapped(currentSong.stream.get_sync_stream_volume(trackList[i][j]), 0.01) )
			if trackList[i][j] == currentlyPlaying[i]:
				musicDebug += " *"
			
			musicDebug += "\n"
	$musicDebug.text = musicDebug
	


##This function runs once per bar
func _on_bar_end_timeout():
	if $musicDebug.visible:
		print("bar ended at ", time) #, " latency: ", AudioServer.get_output_latency()
	StartStop = SSqueue.duplicate()
	
	if time > currentSong.songLength-0.1 or time < 0.1:
		_on_song_end_timeout()
	
	for i in currentlyPlaying.size():
		var vol = int(StartStop[i]) #0 if false, 1 if true
		var clip = currentlyPlaying[i]
		currentSong.stream.set_sync_stream_volume(clip, linear_to_db(vol))
		
	
	
	




##This function runs when the song loops
func _on_song_end_timeout():
	if $musicDebug.visible:
		print("SONG LOOP")
	playingAltTracks = !playingAltTracks
	
	
	for i in trackList.size():
		if trackList[i].size() > 1: #ignore if the track only contains 1 clip
			
			for j in trackList[i]: #Mute all of the clips so we can then play the correct one
				currentSong.stream.set_sync_stream_volume(j, linear_to_db(0))
			
			if playingAltTracks:
				randomize()
				var randIndex = randi_range(1,trackList[i].size()-1)
				currentlyPlaying[i] = trackList[i][randIndex]
			else:
				currentlyPlaying[i] = trackList[i][0]
			
	
	print(currentlyPlaying)
	
	


func _on_button_pressed():
	play_track(2)

func _on_button_2_pressed():
	stop_track(2)
