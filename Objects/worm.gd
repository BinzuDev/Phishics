@icon("res://icons/worm.png")
extends Area3D
class_name Worm

@export var onlyCollectByParry : bool = false
@export var glow : bool = false
##The bigger hitbox thats used to make it easier to grab in midair will be used even if on the floor
@export var forceBigHitbox : bool = false
var collected: bool = false


func _ready():
	$glow.visible = glow
	$OmniLight3D.visible = !glow

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not collected:
		$wormsprite.rotation.y += 0.09 #rotation
	


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is player and not collected and !onlyCollectByParry:
		collect()


func _on_air_hitbox_body_entered(body):
	if body is player and not collected and !onlyCollectByParry:
		#if the player enters the big hitbox while up in the air
		if body.height > 8 or forceBigHitbox: 
			print("COLLECTED WORM IN THE AIR")
			collect() #run the regular function

func _on_parry_detected(_area):
	print("PARRY DETECTED")
	if not collected:
		get_tree().get_first_node_in_group("player").play_shock_wave()
		collect()

func collect():
	ScoreManager.give_points(800,5,true, "WORM")
	ScoreManager.update_freshness(self)
	collected = true
	ScoreManager.increase_counter()
	$WormSFX.play()
	$WormAnimation.play("Collected") #animation
	
