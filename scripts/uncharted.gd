extends Npc

@onready var uncharted : Node3D = $".."

func _ready() -> void:
	if !Global.o7:
		uncharted.queue_free()
