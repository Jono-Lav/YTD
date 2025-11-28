@tool
extends Node3D
class_name DangerZone

@export var radius: float = 1.0:
	set(value):
		radius = value
		if Engine.is_editor_hint():
			var space_state = get_world_3d().direct_space_state
			if space_state:
				update_gizmos() 

func _ready() -> void:
	if Engine.is_editor_hint():
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radius = 0.1
		sphere_mesh.height = 0.2
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = sphere_mesh
		mesh_instance.scale = Vector3(0.2, 0.2, 0.2)
		var material = StandardMaterial3D.new()
		material.albedo_color = Color.YELLOW
		material.flags_unshaded = true
		mesh_instance.material_override = material
		add_child(mesh_instance)
