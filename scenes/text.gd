extends Node3D
@onready var text1 = $Label3D
@onready var button1= $Button
@onready var animation: AnimationPlayer = $"../fade in"

func _ready() -> void:

	await get_tree().create_timer(5.5).timeout
	text1.text="Hey.."
	await get_tree().create_timer(0.5).timeout
	Global.StartTextAnim=true
	await get_tree().create_timer(2).timeout
	text1.text="you died"
	await get_tree().create_timer(2.5).timeout
	text1.text="But dont worry.."
	await get_tree().create_timer(3).timeout
	text1.text="I saved you"
	await get_tree().create_timer(3).timeout
	text1.text="I gave you this.."
	await get_tree().create_timer(3).timeout
	text1.text="a second chance"
	await get_tree().create_timer(4).timeout
	text1.text="Your welcome"
	await get_tree().create_timer(1.5).timeout
	text1.text=""
	await get_tree().create_timer(2).timeout
	text1.text="You're a part of.."
	await get_tree().create_timer(1.75).timeout
	text1.text="something bigger now"
	await get_tree().create_timer(3).timeout
	text1.text="Something you're.."
	await get_tree().create_timer(1).timeout
	text1.text="not meant to understand"
	await get_tree().create_timer(2.4).timeout
	text1.text=""
	await get_tree().create_timer(1).timeout
	text1.text="I know it sounds strange.."
	await get_tree().create_timer(2).timeout
	text1.text="but I need you"
	await get_tree().create_timer(2.5).timeout
	text1.text="I need you here"
	await get_tree().create_timer(2.5).timeout
	text1.text="So don't mess it up"
	await get_tree().create_timer(1.2).timeout
	text1.text=""
	await get_tree().create_timer(4).timeout
	text1.text="Right, I forgot"
	await get_tree().create_timer(2.5).timeout
	text1.text="You dont get to.."
	await get_tree().create_timer(1.3).timeout
	text1.text="keep your memories"
	Global.PearAnim=true
	await get_tree().create_timer(2.5).timeout
	text1.text="Can't risk what.."
	await get_tree().create_timer(1).timeout
	text1.text="happened last time"
	await get_tree().create_timer(2.5).timeout
	text1.text=""
	await get_tree().create_timer(3).timeout
	text1.text="Welcome to.."
	await get_tree().create_timer(2).timeout
	text1.text="Your True Dream"
	await get_tree().create_timer(2.5).timeout
	text1.text="Good luck.."
	await get_tree().create_timer(0.5).timeout
	Global.canStare=true
	await get_tree().create_timer(1).timeout
	text1.text="Second Experience"
	await get_tree().create_timer(2).timeout
	text1.text=""
	await get_tree().create_timer(2).timeout
	Global.canStep=true
	await get_tree().create_timer(0.7).timeout
	text1.text="I will see you in Agartha"
	await get_tree().create_timer(0.4).timeout
	animation.play("fadein")
	await get_tree().create_timer(3.5).timeout
	get_tree().change_scene_to_file("res://scenes/jobFloor.tscn")
	Global.canDrawn=true
	
