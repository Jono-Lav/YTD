@tool
extends Node3D
class_name ShootingPoint

@export var stay_in_place : bool = true:
	set(value):
		stay_in_place = value
		if Engine.is_editor_hint():
			set_top_level(stay_in_place)
		else:
			if is_inside_tree():
				set_top_level(stay_in_place)
		notify_property_list_changed()
@export var Bullets_color : Color = Color(1, 1, 1, 1)
@export var Aim_at_player : bool = true
@export var set_aim : bool = false
@export var fire_rate: float = 0.2 
@export var damage : int = 10
@export var bullet_speed : float = 100.0
@export var bullet_lifetime : float = 5.0

@onready var bullet_scene: PackedScene = preload("res://scenes/Pistol_Bullet.tscn")

func _ready() -> void:
	if Engine.is_editor_hint():
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radius = 0.1
		sphere_mesh.height = 0.2
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = sphere_mesh
		mesh_instance.scale = Vector3(0.2, 0.2, 0.2)
		var material = StandardMaterial3D.new()
		material.albedo_color = Color.RED
		material.flags_unshaded = true
		mesh_instance.material_override = material
		add_child(mesh_instance)
	else:
		set_top_level(stay_in_place)

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		var enemy = get_parent()
		if enemy is Enemy:
			var enemy_body = enemy.enemyBody
			if enemy_body:
				global_transform.origin = enemy_body.global_transform.origin

func set_top_level(value: bool) -> void:
	if top_level != value:
		if value:
			var current_global_pos = global_transform.origin
			top_level = true
			global_transform.origin = current_global_pos
		else:
			top_level = false
			var enemy = get_parent()
			if enemy is Enemy:
				var enemy_body = enemy.enemyBody
				if enemy_body:
					global_transform.origin = enemy_body.global_transform.origin
