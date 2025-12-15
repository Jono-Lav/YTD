extends Interactable

@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var anim = $AnimationPlayer2
@onready var open : AudioStreamPlayer3D = $Open
@onready var close : AudioStreamPlayer3D = $Close

var opened = false

func interact(body):
	if !opened:
		open.play()
		opened = true
		anim.play("open")
		collision.disabled = true
	else:
		close.play()
		opened = false
		anim.play("close")
		collision.disabled = false
		
