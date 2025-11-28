extends Node3D

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var click : AudioStreamPlayer3D = $ClickSound
@onready var player : CharacterBody3D = get_node("/root/" + get_tree().current_scene.name + "/player")
@onready var playerHead : Node3D = get_node("/root/" + get_tree().current_scene.name + "/player/head")
@onready var elevator: Node3D = self  
@onready var text : RichTextLabel = $Label
@onready var lockedSound : AudioStreamPlayer3D = $LockedSound
@onready var buttons := [
	$Node/all/buttons/minus1/minus_one/StaticBody3D/CollisionShape3D,
	$Node/all/buttons/minus2/minus_two/StaticBody3D/CollisionShape3D,
	$Node/all/buttons/zero/zero/StaticBody3D/CollisionShape3D,
	$"Node/all/buttons/1/one/StaticBody3D/CollisionShape3D",
	$Node/all/buttons/thecreator/TC/StaticBody3D/CollisionShape3D,
]

var once : bool = true
var new_scene : bool = false
var prompt : String 

var floor : PackedScene

func _ready() -> void:
	if Global.elevator:
		#this makes the elevatyor in the new scene start with a closed door
		anim.play("door_open(unnecessary)")
		anim.seek(0.0, true)
		anim.stop()
		anim.play("move")
		#this sets the players location and rotation to the variables that were set earlier, this makes the player spawn in the same location and rotation as the previous elevator making the transition seamless and unictue and cool and lior is king andf hamelevh and yonaytanb is loser
		player.global_transform.origin = to_global(Global.player_relative_position)
		var new_elevator_rotation = elevator.global_transform.basis.get_euler()
		player.global_transform.basis = Basis.from_euler(new_elevator_rotation) * Basis.from_euler(Global.player_rotation)
		playerHead.global_transform.basis = Basis.from_euler(new_elevator_rotation) * Basis.from_euler(Global.player_head_rotation)
		#dotn touch that mongrol
		Global.elevator = false
		new_scene = true
		#IF YOU WANNA ADD STuff, DO IT ONLY UNDER THESE LINES, DONT TOUCH ABOVE
		#this happense in the new scene
		#this is to open the door in the new scene, add your own stuff here, this happense after spawning in the new scne
		await get_tree().create_timer(0.7).timeout
		anim.play("door_open(unnecessary)")

func _on_pressed(button: int):
	player = get_node("/root/" + get_tree().current_scene.name + "/player")
	playerHead = get_node("/root/" + get_tree().current_scene.name + "/player/head")
	if once:
		#this disables everybutton in the elevator until you change scenes
		for b in buttons:
			b.disabled = true
		#THIS IS THE SOUND THAT PLAYS WHENEVER YOU PRESS THE BUTTOn
		click.play()
		match button:
			#this is the thing that happense when you press the button not including the sound
			#if you wanna add something to happen when you press each button add it here
			#AGAIN NOT INCLUDNG SOUND
			-2:
				anim.play("press_minus2")
			-1:
				anim.play("press_minus1")
				floor = load("res://scenes/floorMinus1.tscn")
			0:
				anim.play("press_zero")
				Global.showText = true
				Global.prompt = "FLOOR ZERO"
				#this loads the floor into the variable, this is optmized so it only loads the scene for the floor in the button pressed
				floor = load("res://scenes/node_3d.tscn")
			1:
				# this decides wheather to show text whenever entering 
				#the first floor

				Global.showText = true
				#this is the prompt, if you wanna change what it says
				#whenever enetring the floor, change the prompt
				Global.prompt = "FLOOR ONE"
				#note, if you wanna add text to show on other floors
				# just copy this three lines to the code above, like the other numbers
				anim.play("press_one")
				floor = load("res://scenes/floor_1.tscn")
			2:
				anim.play("press_TC")
				floor = load("res://scenes/floor_2.tscn")
		await get_tree().create_timer(0.5).timeout
		anim.play("door_close")
		once = false
		#dont touch this one
		Global.elevator = true
		await get_tree().create_timer(1).timeout
		#stores the location and rotation of the player so it can be replacted in the next scene to make it look seamless
		var elevator_rotation = elevator.global_transform.basis.get_euler()
		Global.player_rotation = (Basis.from_euler(elevator_rotation).inverse() * player.global_transform.basis).get_euler()
		Global.player_head_rotation = (Basis.from_euler(elevator_rotation).inverse() * playerHead.global_transform.basis).get_euler()
		Global.player_relative_position = to_local(player.global_transform.origin)
		#changes floor
		#IF YOU WANNA ADD STUFF DO IT HERE, BEFORE YOU CHANGE SCENEs, BUT DONT TOUCH above
		#UNLESS YOU WANNA CHANGE WHAT HAPPENSE WHEN YOU PRESS BUTTONS
		#THAT IS ALLOWED
		#BUT DONT CHANGE THE RESt !!! VERY IMPORTANT S
		anim.play("move")
		await anim.animation_finished
		anim.play("move")
		await anim.animation_finished
		get_tree().change_scene_to_packed(floor)

func _on_locked(button: int):
	lockedSound.play()
	anim.play("locked_minus2")
	anim.seek(0.0, false)
	anim.play("locked_minus1")
	anim.seek(0.0, false)
	anim.play("locked_zero")
	anim.seek(0.0, false)
	anim.play("locked_one")
	anim.seek(0.0, false)
	anim.play("locked_two")
	anim.seek(0.0, false)
	match button:
		-2:
			anim.play("locked_minus2")
		-1:
			anim.play("locked_minus1")
		0:
			anim.play("locked_zero")
		1:
			anim.play("locked_one")
		2:
			anim.play("locked_two")

func _on_area_3d_body_exited(body: Node3D) -> void:
	if Global.showText and new_scene and body == player:
		Global.showText = false
		new_scene = false
		text.visible = true
		text.text = "[pulse color=#ffffff33 freq=1.0 ease=-2.0 height=0][shake freq=1.5 width=10 height=10][b]"+ Global.prompt +"[/b][/shake][/pulse]"
		await get_tree().create_timer(5).timeout
		text.visible = false
		text.text = ""
