@tool
extends Control

@export var label : String = "Goal #1"
@export var valueToTrack : String = "highjump"
@export_range(1, 9) var total : int = 3


var valueLastFrame : int = 0

func _process(delta):
	if Engine.is_editor_hint():
		$Control/Label.text = str(label, " (0/", total, ")")
	else:
		if ScoreManager.tutorialChecklist.has(valueToTrack):
			var value = ScoreManager.tutorialChecklist[valueToTrack]
			if total > 1:
				$Control/Label.text = str(label," (",value,"/",total,")")
			else:
				$Control/Label.text = label
			
			if valueLastFrame != value:
				if value == total:
					$AnimationPlayer.play("reach_max")
				else:
					$AnimationPlayer.play("count_up")
			
			valueLastFrame =  ScoreManager.tutorialChecklist[valueToTrack]
