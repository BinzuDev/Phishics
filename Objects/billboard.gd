@tool
extends Node3D

@export_file("*.png") var billboardTexture := "res://Models/billboard/billboard_ads/billboard_ad_saul.png":
	set(new_value):
		billboardTexture = new_value
		if get_node_or_null("billboardMesh"):
			print("test")
			$billboardMesh.get_surface_override_material(4).albedo_texture = load(billboardTexture)
		
