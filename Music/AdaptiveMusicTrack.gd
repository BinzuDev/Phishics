@icon("res://Icons/waveform.png")
extends AudioStreamPlayer
class_name AdaptiveMusicTrack

#region Constants
##To use my custom Adaptive music object, place every single clip you want to use
##inside an [AudioStreamSynchronized] resource inside the Stream proprety.
##Lets define keywords for clarity: Clip means a single audio file. 
##A track is a group of clips where only one clip can play at a time.
#endregion


##This tells the game how many tracks the song has.
##if the song has 6 clips and 3 tracks, then clip 0/1/2 is going to be used as the default clip for track 0/1/2. 
##clip 3/4/5 can then be used as alternative clips however you want.
@export var trackCount : int = 1
##The BPM of the song, this is used to figure out how long one beat/bar should be (4/4 is assumed)
@export var BPM : float = 150.0
##How long the song is in seconds. Used to figure out when tracks should switch on end.
@export var songLength : float = 51.2

##This is how you link clips to tracks. 
##The index is the clip index (START COUNTING FROM 0)
##and Value is the track index (AGAIN, START COUNTING FROM 0)
@export var clipGrouping : Array[int]

##Get how long in seconds 1 beat is at the song's BPM.
func get_beat_length():
	return 1 / (BPM / 60)

##Get how long in seconds 1 bar isat the song's BPM.
func get_bar_length():
	return get_beat_length()*4
