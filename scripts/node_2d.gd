extends Node2D

@onready var te = $Label
@onready var bu = $Button 

var a = false
var b = false

func _on_button_pressed() -> void:
	te.text = "Do you feel it?"
	te.position.x = 100
	bu.queue_free() #destroy
	await get_tree().create_timer(3.5).timeout
	te.text = "Strange, isn’t it?"
	await get_tree().create_timer(4.0).timeout
	te.text = "Thinking without"
	await get_tree().create_timer(2).timeout
	te.text = "knowing who you are"
	await get_tree().create_timer(4.0).timeout
	te.text = "I gave you this... "
	await get_tree().create_timer(3.0).timeout
	te.text = "a second chance "
	await get_tree().create_timer(4.0).timeout
	te.text = "Welcome"
	await get_tree().create_timer(2).timeout
	te.text = "to Your True Dream"
	await get_tree().create_timer(4.0).timeout
	te.text = "let's begin"
	await get_tree().create_timer(3.5).timeout
	te.text = "making.."
	await get_tree().create_timer(1.5).timeout
	te.text = "exit code 0"
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://scenes/jobFloor.tscn")


func _on_texture_button_pressed() -> void:
	if !a && b:
		a = true
	elif a:
		a = false


func _on_texture_button_2_pressed() -> void:
	if a and b:
		get_tree().change_scene_to_file("res://scenes/jobFloor.tscn")
	elif !a:
		b = true
