extends Interactable

@onready var anim : AnimationPlayer = $"../AnimationPlayer2"
@onready var hit : AudioStreamPlayer3D = $hit
@onready var s1: AudioStreamPlayer3D = $PitchTrigger/ambiance/AudioStreamPlayer3D
@onready var s2: AudioStreamPlayer3D = $PitchTrigger/ambiance/AudioStreamPlayer3D2
@onready var s3: AudioStreamPlayer3D = $PitchTrigger/ambiance/AudioStreamPlayer3D3
@onready var s4: AudioStreamPlayer3D = $PitchTrigger/ambiance/AudioStreamPlayer3D4

func interact(body):
	$CollisionShape3D.disabled = true
	DialogueManager.show_example_dialogue_balloon(load("res://dialogue/shaver.dialogue"))
	await get_tree().create_timer(3.5).timeout
	DialogueManager.show_example_dialogue_balloon(load("res://dialogue/shaver2.dialogue"))
	await get_tree().create_timer(3.5).timeout
	hit.play()
	s1.stop()
	s2.stop()
	s3.stop()
	s4.stop()
	anim.stop()
	await get_tree().create_timer(0.5).timeout
	DialogueManager.show_example_dialogue_balloon(load("res://dialogue/shaverDeath.dialogue"))
	await get_tree().create_timer(1.3).timeout
	anim.seek(1.0, true)
	anim.play()
	hit.play()
	await get_tree().create_timer(1).timeout
	hit.play()	
	await get_tree().create_timer(1).timeout
	hit.play()
	await get_tree().create_timer(1.6).timeout
	hit.play()
	Global.o6 = false
	Global.playerStop = false
	Global.canSprint = true
	Global.canJump = true
	Global.missionCompleted = true
	get_tree().change_scene_to_file("res://scenes/floor_1.tscn")
