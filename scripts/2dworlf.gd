extends Mission

@onready var label : Label = $Label
@onready var soundstatic : AudioStreamPlayer = $AudioStreamPlayer

var timer : float = 30.0
var timertimer : float = 0.0

func _process(delta: float) -> void:
	if timer > 0:
		label.text = str(int(timer))
		timertimer += delta
		if timertimer >= 1.0:
			timertimer = 0.0
			timer -= 1.0
	else:
		label.text = "bye bye"
		soundstatic.play()
		timertimer += delta
		soundstatic.volume_db += 0.1
		if timertimer >= 3.5:
			Global.missionFailed = true
			get_tree().change_scene_to_file("res://scenes/node_3d.tscn")
