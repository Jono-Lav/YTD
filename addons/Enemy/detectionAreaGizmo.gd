@tool
extends EditorNode3DGizmoPlugin

func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is Enemy

func _create_gizmo(for_node_3d: Node3D) -> EditorNode3DGizmo:
	if for_node_3d is Enemy:
		return EnemyGizmo.new(for_node_3d)
	return null
