extends Node3D

@onready var npc3anim : AnimationPlayer = $Npc3/body/anim
@onready var npc3dialoguecollision : CollisionShape3D = $Npc3/body/collision
@onready var unkownanim : AnimationPlayer = $Unknown/body/anim
@onready var unkowndialoguecollision : CollisionShape3D = $Unknown/body/collision
@onready var npc4anim : AnimationPlayer = $Npc4/npc4body/anim
@onready var npc4oguecollision : CollisionShape3D = $Npc4/npc4body/dialoguecollision
@onready var player : CharacterBody3D = $player
@onready var floatinpieceAnim : AnimationPlayer = $roof_extended2/AnimationPlayer
@onready var floatinpieceAnim2 : AnimationPlayer = $Walls/Node/AnimationPlayer
@onready var unknown : Node3D = $Unknown

func _ready() -> void:
	unkownanim.get_animation("test/un_lean").length = 1.0
	unkownanim.get_animation("test/un_lean").loop = true
	unkownanim.get_animation("test/un_lean_clap").length = 1.0
	unkownanim.get_animation("test/un_lean_clap").loop = true
	unkownanim.get_animation("test/un_lean_pointUP").length = 1.0
	unkownanim.get_animation("test/un_lean_pointUP").loop = true
	unkownanim.play("test/un_lean")
	#floatinpieceAnim.get_animation("new_animation").length = 17.5
	#floatinpieceAnim.get_animation("new_animation").loop_mode = Animation.LOOP_PINGPONG
	#floatinpieceAnim.get_animation("new_animation").loop = true
	#floatinpieceAnim2.get_animation("new_animation").length = 17.5
	#floatinpieceAnim2.get_animation("new_animation").loop_mode = Animation.LOOP_PINGPONG
	#floatinpieceAnim2.get_animation("new_animation").loop = true
	#floatinpieceAnim.play("new_animation")
	#floatinpieceAnim2.play("new_animation")
	if !Global.o7:
		unknown.queue_free()
