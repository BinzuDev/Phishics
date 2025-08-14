extends CanvasLayer

@export var speed_effect_color_rect:ColorRect

func _ready() -> void:
	ApplySpeedEffect.effect_change.connect(apply_effect)
	
func apply_effect(value:float) -> void:
	speed_effect_color_rect.material.set_shader_parameter('effect_power', value)
