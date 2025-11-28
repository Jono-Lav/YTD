@tool
class_name EnemyGizmo
extends EditorNode3DGizmo

var node : Node3D
var detection_material : StandardMaterial3D
var handle_material : StandardMaterial3D

func _init(for_node3D : Node3D) -> void:
	self.node = for_node3D
	detection_material = StandardMaterial3D.new()
	detection_material.albedo_color = Color(0.0, 1.0, 0.0, 0.3)
	detection_material.flags_transparent = true
	detection_material.flags_unshaded = true
	handle_material = StandardMaterial3D.new()
	handle_material.albedo_color = Color(1.0, 1.0, 0.0) 
	handle_material.flags_unshaded = true

func _redraw() -> void:
	clear()
	if not node is Enemy:
		return
	var enemy : Enemy = node as Enemy
	if not enemy.use_detection_area or enemy.detection_radius <= 0.0:
		return
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = enemy.detection_radius
	sphere_mesh.height = enemy.detection_radius * 2
	sphere_mesh.radial_segments = 32
	sphere_mesh.rings = 16
	sphere_mesh.material = detection_material
	var offset = Vector3.ZERO
	if enemy.static_detection_area:
		var detection_area = enemy.get_node_or_null("DetectionArea")
		if detection_area:
			offset = detection_area.global_position - enemy.global_position
	add_mesh(sphere_mesh, null, Transform3D(Basis(), offset))
	var outline_material = StandardMaterial3D.new()
	outline_material.albedo_color = Color(0.0, 1.0, 0.0, 1.0)
	outline_material.flags_unshaded = true
	var lines = PackedVector3Array()
	var segments = 32
	for i in range(segments + 1):
		var angle = i * 2.0 * PI / segments
		var x = cos(angle) * enemy.detection_radius
		var z = sin(angle) * enemy.detection_radius
		lines.append(Vector3(x, 0, z))
	for i in range(segments + 1):
		var angle = i * 2.0 * PI / segments
		var y = cos(angle) * enemy.detection_radius
		var z = sin(angle) * enemy.detection_radius
		lines.append(Vector3(0, y, z))
	for i in range(segments + 1):
		var angle = i * 2.0 * PI / segments
		var x = cos(angle) * enemy.detection_radius
		var y = sin(angle) * enemy.detection_radius
		lines.append(Vector3(x, y, 0))
	add_lines(lines, outline_material)
	var handles = PackedVector3Array()
	handles.append(Vector3(enemy.detection_radius, 0, 0))
	handles.append(Vector3(-enemy.detection_radius, 0, 0))
	handles.append(Vector3(0, enemy.detection_radius, 0))
	handles.append(Vector3(0, -enemy.detection_radius, 0))
	handles.append(Vector3(0, 0, enemy.detection_radius))
	handles.append(Vector3(0, 0, -enemy.detection_radius))
	var handle_ids = [0, 1, 2, 3, 4, 5]
	add_handles(handles, handle_material, handle_ids)

func _set_handle(id: int, secondary: bool, camera: Camera3D, point: Vector2) -> void:
	var enemy: Enemy = node as Enemy
	var global_pos = node.global_transform.origin
	var ray_start = camera.project_ray_origin(point)
	var ray_dir = camera.project_ray_normal(point)
	var t = ray_dir.dot(global_pos - ray_start) / ray_dir.dot(ray_dir)
	var hit_pos = ray_start + ray_dir * t
	var local_pos = node.global_transform.affine_inverse() * hit_pos
	var new_radius = local_pos.length()
	enemy.detection_radius = max(new_radius, 0.1)
	enemy._update_detection_area()
	set_node_3d(node)

func _get_handle_name(id: int, secondary: bool) -> String:
	return "Detection Radius"

func _get_handle_value(id: int, secondary: bool) -> Variant:
	var enemy : Enemy = node as Enemy
	return enemy.detection_radius

func _commit_handle(id: int, secondary: bool, restore: Variant, cancel: bool) -> void:
	var enemy : Enemy = node as Enemy
	if cancel:
		enemy.detection_radius = restore
	else:
		var undo_redo = EditorInterface.get_editor_undo_redo()
		undo_redo.create_action("Change Detection Radius")
		undo_redo.add_do_property(enemy, "detection_radius", enemy.detection_radius)
		undo_redo.add_undo_property(enemy, "detection_radius", restore)
		undo_redo.commit_action()
