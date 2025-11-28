extends Npc

var once : bool = true

func _on_trigger_body_entered(body: Node3D) -> void:
	if once:
		anim.play("n4/Npc4_headtilit")
		once = false
