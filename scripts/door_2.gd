extends Interactable

@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var anim : AnimationPlayer = $AnimationPlayer2
@onready var anim2 : AnimationPlayer = $AnimationPlayer
@onready var open : AudioStreamPlayer3D = $Open
@onready var close : AudioStreamPlayer3D = $Close

var opened : bool 

func _ready() -> void:
	prompt = "Close" if name.contains("3") else "Open"

func interact(body):
	if anim.is_playing():
		return
	if !opened:
		open.play()
		anim.play("open")
		anim2.play("open")
		await anim.animation_finished
	else:
		close.play()
		anim.play("close")
		anim2.play("close")
		await anim.animation_finished
	if name.contains("3"):
		prompt = "Open" if !opened else "Close"
	else:
		prompt = "Close" if !opened else "Open"
	opened = !opened 
