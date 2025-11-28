extends TextEdit

@onready var paper = $".."
@onready var root : Node3D = $"../../../.."

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER and root.af:
		Global.player_name = text
		paper.visible = false
		root.done = true
		root.af = false
		DialogueManager.show_example_dialogue_balloon(load("res://dialogue/oval2.dialogue"))
