@tool
extends EditorNode3DGizmoPlugin

func _init() -> void:
	create_material("lines", Color.YELLOW, true, true)

func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is DangerZone

func _create_gizmo(for_node_3d: Node3D) -> EditorNode3DGizmo:
	if for_node_3d is DangerZone:
		return preload("res://addons/Enemy/danger zone/dangerzonegizmoCLass.gd").new(for_node_3d, self)
	return null
