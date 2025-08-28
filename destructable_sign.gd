@tool
extends RigidBody3D
var touched: bool = false

#allows us to switch sprites
@export_file("*.png") var Sign_Sprite: String = "res://Sprites/signs/" : 
	set(new_value):
		Sign_Sprite = new_value
		if Engine.is_editor_hint():
			$Sprite3D.texture = load(new_value) #changes sprites real time



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite3D.texture = load(Sign_Sprite)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is player:
		gravity_scale= 1 #when player touches it, it falls
	
	
	if not touched and body is player: #destruction points
		ScoreManager.give_points(100, 1, false, "DESTRUCTION")
		ScoreManager.play_trick_sfx("uncommon")
		touched = true
		
