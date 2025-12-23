extends Node3D


@export var length : float = 50

@onready var skinCount := $Skins.get_child_count()

var currentId : int = 0

#keeps track of the ID of the last skin in the database
var maxSkin : int = 1

func _ready():
	maxSkin = GameManager.database.skins.size()
	set_skin_carousel()



func _physics_process(delta):
	if !$AnimationPlayer.is_playing():
		if Input.is_action_just_pressed("left"):
			$AnimationPlayer.play("move_right")
			currentId = wrap(currentId-1, 0, maxSkin)
			$Skins/skinBehind.quick_set_skin(currentId-2)
		if Input.is_action_just_pressed("right"):
			$AnimationPlayer.play("move_left")
			currentId = wrap(currentId+1, 0, maxSkin)
			$Skins/skinBehind.quick_set_skin(currentId+2)
	


func _on_animation_finished(anim_name):
	set_skin_carousel()


func set_skin_carousel():
	$Skins/skinFarLeft.position = Vector3(-4,0,-4)
	$Skins/skinLeft.position = Vector3(-2.6,0,-0.7)
	$Skins/skinCenter.position = Vector3(0,0,0)
	$Skins/skinRight.position = Vector3(2.6,0,-0.7)
	$Skins/skinFarRight.position = Vector3(4.0,0,-4.0)
	$Skins/skinBehind.position = Vector3(0,0,-8.0)
	$Skins/skinFarLeft.quick_set_skin(currentId-2)
	$Skins/skinLeft.quick_set_skin(currentId-1)
	$Skins/skinCenter.quick_set_skin(currentId)
	$Skins/skinRight.quick_set_skin(currentId+1)
	$Skins/skinFarRight.quick_set_skin(currentId+2)
