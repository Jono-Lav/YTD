extends Node
class_name Mission

var previous_scene: Node
var previous_scene_path : String 
var previous_scene_packed : PackedScene
var orb : StaticBody3D

func _init() -> void:
	previous_scene = Global.previousScene
	if previous_scene:
		orb = previous_scene.find_child("orb", true, false)
		previous_scene_path = previous_scene.scene_file_path
		previous_scene_packed = load(previous_scene_path)

func complete_mission():
	Global.missionCompleted = true
	if previous_scene_packed != null:
		get_tree().change_scene_to_packed(previous_scene_packed)
	else:
		print("Warning: Previous scene not set or found for mission completion")

func fail_mission():
	Global.missionCompleted = true
	if previous_scene_packed != null :
		get_tree().change_scene_to_packed(previous_scene_packed)
	else:
		print("Warning: Previous scene path not set or found for mission failure")
