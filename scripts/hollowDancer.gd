extends StaticBody3D

@onready var enemy : Enemy = $Enemy
@onready var trees : Node = $"../trees"
var original : int = -0.239
var original_pos : Vector3
var target : int = 12.987
var count : int = 1

func _ready() -> void:
	original_pos = position

func move():
	position.z += 5.1
	count += 1
	if count >= 3:
		count = 0
		trees.stop = true
		enemy.state = enemy.State.FOLLOW

func reset():
	position = original_pos
	count = 0
