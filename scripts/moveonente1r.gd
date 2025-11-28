extends StaticBody3D

@onready var anim = $AnimationPlayer
@onready var thud = $thud
var once = true

func _process(delta: float) -> void:
	if Global.entered1 and anim.animation_finished && once:
		anim.play("moveonenter1")
		thud.play()
		Global.entered1 = false
		once = false
