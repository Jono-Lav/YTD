extends Interactable

@onready var root : Node3D = $".."
@onready var sound : AudioStreamPlayer3D = $paperSound

func interact(body):
	root.numbersCollected += 1
	sound.play(0.15)
	await get_tree().create_timer(0.4).timeout
	queue_free()
