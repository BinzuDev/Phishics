@icon("res://icons/dialogueBranch.png")
class_name DialogueBranch extends Resource


@export var choice : int = 0
@export var condition : String = ""

@export_node_path("DialogueArea") var defaultDialogue
@export_node_path("DialogueArea") var ifConditionIsTrue
