class_name ShootingPointGizmo
extends EditorNode3DGizmo

var node : Node3D

func _init(for_node3D : Node3D) -> void:
	self.node = for_node3D

func _redraw() -> void:
	clear()
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.RED
	material.flags_unshaded = true  
	material.flags_no_depth_test = true  
	var mesh = SphereMesh.new()
	mesh.radius = 0.1  
	mesh.height = 0.2  
	add_mesh(mesh, material)
