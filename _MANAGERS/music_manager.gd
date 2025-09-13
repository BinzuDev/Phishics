extends Node

@onready var currentSong : AdaptiveMusicTrack = $AdaptiveMusicTrack



##Start/Stop queue. keeps track of which clip should start or stop on the next bar.
##FALSE means that the clip should stop, TRUE means that it should start
var SSqueue : Array = []
##List of which track are currently fading in or fading out, only updates every bar
var StartStop : Array = []

##Contains a list of all tracks, each containing a list of all clips in said tracks
var trackList : Array = [] 
##If you want to know which track a clip is part of, use currentSong.clipGrouping.get(x)

##Everytime the song loops, this variable flips
##This is what makes the tracks alternate between the default clips and the extra clips
var playingAltTracks : bool = false



func _ready():
	reset_music()
	print(SSqueue)
	

func reset_music():
	##Set the song length and beat length
	$barEnd.stop() 
	#wait only 3 beats at the very start, this is so that the fade out ends BY THE END of
	#the bar, instead of reaching the end of the bar AND THEN fading out while the next bar starts playing
	$barEnd.wait_time = currentSong.get_beat_length() * 3
	$barEnd.start()
	$barEnd.wait_time = currentSong.get_beat_length() * 4
	$songEnd.stop()
	$songEnd.wait_time = currentSong.songLength #6
	$songEnd.start()
	##Instantiate the wait queue and fade lists
	SSqueue.resize(currentSong.stream.stream_count)
	StartStop.resize(currentSong.stream.stream_count)
	for i in SSqueue.size():
		SSqueue[i] = false
		StartStop[i] = false
	SSqueue[0] = true
	StartStop[0] = true
	##Instantiate the 2D list of tracks and clips
	trackList = []
	for i in currentSong.trackCount:
		trackList.append([])
	for clipIndex in currentSong.clipGrouping:
		var track = currentSong.clipGrouping.get(clipIndex)
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
	





func _process(_delta):
	
	##Fade in/out
	for i in StartStop.size():
		var vol = db_to_linear(currentSong.stream.get_sync_stream_volume(i))
		if StartStop[i] == true:
			#fade in
			vol = move_toward(vol, 1, 0.05)
			currentSong.stream.set_sync_stream_volume(i, linear_to_db(vol))
		else:
			#fade out
			vol = move_toward(vol, 0, 0.05)
			currentSong.stream.set_sync_stream_volume(i, linear_to_db(vol))
	
	
	##Debug
	var musicDebug = ""
	for i in currentSong.stream.stream_count:
		musicDebug += str("Clip #",i, " (track #", get_clip_track(i), ") db: ", snapped(currentSong.stream.get_sync_stream_volume(i), 0.01) )
		musicDebug += str(" queued: ", SSqueue[i])
		musicDebug += str(" playing: ", StartStop[i])
		if SSqueue[i] == true and StartStop[i] == false:
			musicDebug += str(" (queued to start)")
		if SSqueue[i] == false and StartStop[i] == true:
			musicDebug += str(" (queued to stop)")
		musicDebug += "\n"
	$musicDebug.text = musicDebug
	


##This function runs once per bar (specifically on the 3rd beat)
func _on_bar_end_timeout():
	if $musicDebug.visible:
		print("bar end")
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
func get_clip_track(index:int):
	return currentSong.clipGrouping.get(index)
