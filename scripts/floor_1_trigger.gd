extends Node3D

@onready var player : CharacterBody3D = get_node("/root/" + get_tree().current_scene.name + "/player")
@onready var playerHead : Node3D = get_node("/root/" + get_tree().current_scene.name + "/player/head")

func _ready() -> void:
	if Global.fell:
		Global.fell = false
		player.rotation = Global.player_rotation
		playerHead.rotation = Global.player_head_rotation
		player.position.y = 35

func _on_area_3d_body_entered(body: Node3D) -> void:
	player = get_node("/root/" + get_tree().current_scene.name + "/player")
	playerHead = get_node("/root/" + get_tree().current_scene.name + "/player/head")
	Global.player_rotation = player.rotation
	Global.player_head_rotation = playerHead.rotation
	Global.fell = true
	match get_tree().current_scene.name:
		"floor_1":
			get_tree().change_scene_to_file("res://scenes/node_3d.tscn")
		"floor2":
			get_tree().change_scene_to_file("res://scenes/floor_1.tscn")
		"world":
			get_tree().change_scene_to_file("res://scenes/floorMinus1.tscn")
		"floorMinus1":
			get_tree().change_scene_to_file("res://scenes/floorMinus1.tscn")
