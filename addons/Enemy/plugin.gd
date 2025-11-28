@tool
extends EditorPlugin

var dangeer_gizmo_plugin = preload("res://addons/Enemy/danger zone/dangerZoneGizmo.gd")
var area_gizmo_plugin = preload("res://addons/Enemy/detectionAreaGizmo.gd").new()
var gizmo_plugin = preload("res://addons/Enemy/shooting_point_gizmo.gd").new()
var editor_interface : EditorInterface
var inspector_plugin : EditorInspectorPlugin 

func _enter_tree() -> void:
	editor_interface = get_editor_interface()
	inspector_plugin = preload("res://addons/Enemy/inspector_plugin.gd").new(editor_interface)
	add_inspector_plugin(inspector_plugin)
	
	add_node_3d_gizmo_plugin(gizmo_plugin)
	add_node_3d_gizmo_plugin(area_gizmo_plugin)
	add_custom_type("Enemy", "Node3D", preload("res://addons/Enemy/enemy.gd"), preload("res://icon.svg"))
	add_custom_type("ShootingPoint", "Node3D", preload("res://addons/Enemy/shooting_point.gd"), preload("res://icon.svg"))
	add_custom_type("DangerZone", "Node3D", preload("res://addons/Enemy/danger zone/danger_zone.gd"), preload("res://icon.svg"))

func _exit_tree() -> void:
	remove_node_3d_gizmo_plugin(gizmo_plugin)
	remove_node_3d_gizmo_plugin(area_gizmo_plugin)
	remove_inspector_plugin(inspector_plugin)
	remove_custom_type("Enemy")
	remove_custom_type("ShootingPoint")
	remove_custom_type("DangerZone")
