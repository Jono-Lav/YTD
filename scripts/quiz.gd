extends Node2D

@onready var text = $TextEdit
@onready var getout = $AudioStreamPlayer
@onready var wrong = $wrong
@onready var correct = $AudioStreamPlayer2
@onready var animation = $AnimationPlayer
@onready var question = $Label

var count = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	question.text = "enter your name"
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_button_pressed() -> void:
	if count == 1:
		if text.text == "lior":
			getout.play()
		elif text.text == "booming":
			animation.play("correct")
			correct.play()
		else:
			animation.play("wrong")
			wrong.play()
		text.clear()
		count += 1
		await get_tree().create_timer(1.3).timeout
		$wate.visible = false
		$sand.visible = true
		question.text = "how was your day"
	elif count == 2:
		if text.text == "booming":
			getout.play()
		elif text.text == "lior":
			animation.play("correct")
			correct.play()
		else:
			animation.play("wrong")
			wrong.play()
		text.clear()
		count += 1
		await get_tree().create_timer(1.3).timeout
		$sand.visible = false
		$spon.visible = true
		question.text = "who is this"
	elif count == 3:
		if text.text == "god":
			getout.play()
		elif text.text == "lior":
			animation.play("correct")
			correct.play()
		else:
			animation.play("wrong")
			wrong.play()
		text.clear()
		await get_tree().create_timer(1.3).timeout
		get_tree().change_scene_to_file("res://scenes/node_3d.tscn")
