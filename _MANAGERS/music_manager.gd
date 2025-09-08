extends Node

@onready var tracks = [$music0, $music1, $music2, $music3, $music4]


func _ready():
	pass

func stop_music():
	stop_track(1)
	stop_track(2)
	stop_track(3)
	stop_track(4)


func stop_track(trackIndex : int):
	if trackIndex == 0:
		printerr("Sorry you can't stop the base track!")
	else:
		tracks[trackIndex].get_stream_playback().switch_to_clip(0)


func play_track(trackIndex : int, clipIndex : int):
	
	if trackIndex <= 3:
		tracks[trackIndex].get_stream_playback().switch_to_clip(clipIndex)
	
	if trackIndex == 3:      ## randomize between backing 1-3  TODO: this is hardcoded for the current setup 
		$music3.get_stream().set_clip_auto_advance_next_clip(1, randi_range(2,4))
	
	if trackIndex == 4:  
		var track3 = $music3.get_stream_playback().get_current_clip_index()
		if track3 <= 1: 
			$music4.get_stream_playback().switch_to_clip(1)
			$music4.get_stream().set_clip_auto_advance_next_clip(1, randi_range(2,3))
		else:
			$music4.get_stream_playback().switch_to_clip(randi_range(2,3))
	
	

func _process(_delta):
	var musicDebug = [  ##extremely rough music debug
	"calm1",
	$music1.stream.get_clip_name($music1.get_stream_playback().get_current_clip_index()),
	$music2.stream.get_clip_name($music2.get_stream_playback().get_current_clip_index()),
	$music3.stream.get_clip_name($music3.get_stream_playback().get_current_clip_index()),
	$music4.stream.get_clip_name($music4.get_stream_playback().get_current_clip_index())
	]
	$musicDebug.text = str("Now Playing: ", musicDebug)
	
	#print($music3.get_stream_playback().get_current_clip_index())
	#print($music3.stream.get_clip_name($music3.get_stream_playback().get_current_clip_index()) )
