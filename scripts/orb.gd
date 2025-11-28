extends StaticBody3D

@onready var player : CharacterBody3D = get_node("/root/" + get_tree().current_scene.name + "/player")
@onready var sound : AudioStreamPlayer3D = $AudioStreamPlayer3D2
@onready var label : RichTextLabel= $Label
@onready var area3d : Area3D = $Area3D

@export var orb : int
@export var scene : PackedScene
@export var locked_prompt : String = "NEED OWNER PERMISSION"

var time_passed = 0.0
var start_y = 0.0
var float_amplitude = 0.1  
var float_speed = 1.0
var rotation_speed = Vector3(20, 30, 0)

func _ready() -> void:
	var orbName = "o" + str(orb)
	start_y = position.y
	if orbName in Global:
		if !Global[orbName]:
			queue_free()
	if Global.missionFailed:
		Global.missionFailed = false
		_on_mission_failed()
	elif Global.missionCompleted:
		Global.missionCompleted = false
		_on_mission_completed()

func _process(delta: float) -> void:
	time_passed += delta
	var float_offset = sin(time_passed * float_speed) * float_amplitude
	position.y = start_y + float_offset

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		
		var orbName = "o" + str(orb)
		var permissionName = orbName + "permission"
		
		if orbName in Global and permissionName in Global:
			if Global[permissionName]:  
				Global[orbName] = false
				Global.previousScene = get_tree().current_scene
				Getout.play()
				if scene:
					get_tree().change_scene_to_packed(scene)
				else:
					_on_mission_completed()
				queue_free()
			else:
				label.text = "[pulse freq=1.0 color=#ffffff33 ease=-2.0 height=0][shake freq=1.0 height=0][b]"+ locked_prompt +"[/b][/shake][/pulse]"
				await get_tree().create_timer(2).timeout
				label.text = ""

func _on_mission_completed():
	player.scoreUpdate()
	Global.score += 1

func _on_mission_failed():
	#Global.score -= 1
	pass
