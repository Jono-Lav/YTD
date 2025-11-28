extends ColorRect

func _ready() -> void:
	material.set_shader_parameter("pixel_width", 4)
	material.set_shader_parameter("arm_length_pixels", 30)
