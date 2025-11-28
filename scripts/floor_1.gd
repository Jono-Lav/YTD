extends Node3D

@onready var redReaperAnim : AnimationPlayer = $RedReaper/AnimationPlayer2
@onready var rotemInteractableCollision : CollisionShape3D = $RedReaper/StaticBody3D/CollisionShape3D
@onready var anim : AnimationPlayer = $wakeUpCutScene/cutscene_anim
@onready var player : CharacterBody3D = $player
@onready var cutSceneCam : Camera3D = $wakeUpCutScene/cutscene_cam
@onready var transition : AnimationPlayer = $wakeUpCutScene/Transition
@onready var Aplayer : PackedScene = preload("res://scenes/player.tscn")
@onready var Bplayer : CharacterBody3D = $wakeUpCutScene/player

func _ready() -> void:
	if !Global.o6 and Global.onceCutScene:
		Global.onceCutScene = false
		transition.play("fade_in")
		Global.playerStop = true
		player.queue_free()
		await get_tree().create_timer(1.0).timeout
		anim.play("wakeUp")
		await anim.animation_finished
		Global.playerStop = false
		var instance = Aplayer.instantiate()
		add_child(instance)
		instance.global_position = Bplayer.global_position
		instance.rotation = Bplayer.rotation 
		instance.scoreUpdate(1)
		Bplayer.queue_free()
		cutSceneCam.queue_free()
	else:
		transition.queue_free()
