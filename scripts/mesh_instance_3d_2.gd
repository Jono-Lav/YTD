extends MeshInstance3D

@onready var object = $MeshInstance3D

var target_position : Vector3 = Vector3(10, 0, 10)
var move_speed : float = 5.0
var current_position : Vector3

func _on_area_3d_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	$MeshInstance3D/AnimationPlayer.play("move")
