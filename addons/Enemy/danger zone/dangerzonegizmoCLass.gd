class_name DangerZoneGizmo
extends EditorNode3DGizmo

var node : Node3D
var plugin = EditorNode3DGizmoPlugin

func _init(for_node_3d: Node3D, gizmo_plugin: EditorNode3DGizmoPlugin) -> void:
	self.node = for_node_3d
	self.plugin = gizmo_plugin

func _redraw() -> void:
	clear()
	var material = plugin.get_material("lines", self)
	var space_state = node.get_viewport().world_3d.direct_space_state
	if not space_state:
		return
	
	var radius = node.radius if "radius" in node else 1.0
	radius = max(radius, 0.01)
	var center = node.global_transform.origin
	var num_segments = 32
	var hits_by_height = {}
	
	for i in range(num_segments):
		var angle = i * 2.0 * PI / num_segments
		var offset = Vector3(cos(angle), 0, sin(angle)) * radius
		var from = center + offset + Vector3(0, 10000, 0)
		var to = center + offset + Vector3(0, -10000, 0)
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var result = space_state.intersect_ray(query)
		if result:
			var y = snapped(result.position.y, 0.1)
			if y not in hits_by_height:
				hits_by_height[y] = []
			hits_by_height[y].append(result.position)
	
	for height in hits_by_height:
		var points = []
		for i in range(num_segments + 1):
			var angle = i * 2.0 * PI / num_segments
			var point = Vector3(cos(angle) * radius, 0, sin(angle) * radius) + Vector3(center.x, height, center.z)
			points.append(point)
		for i in range(num_segments):
			add_lines([points[i], points[i + 1]], material)
