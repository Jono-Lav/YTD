@tool
extends EditorNode3DGizmoPlugin

func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is ShootingPoint

func _create_gizmo(for_node_3d: Node3D) -> EditorNode3DGizmo:
	if for_node_3d is ShootingPoint:
		return ShootingPointGizmo.new(for_node_3d)
	return null
