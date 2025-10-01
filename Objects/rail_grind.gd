extends PathFollow3D

var fish: Node3D

func _ready():
	fish = get_tree().get_first_node_in_group("player")

func _process(_delta):
	if fish and get_parent() is Path3D:
		var path_3d = get_parent() as Path3D
		var curve = path_3d.curve
		
		var target_position = path_3d.to_local(fish.global_position)
		var closest_offset = curve.get_closest_offset(target_position) #makes the hitbox follow the fish
		
		self.progress = closest_offset


func _on_area_entered(body):
	body.reparent(self)
