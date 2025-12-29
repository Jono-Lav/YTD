extends Npc

@onready var foreign = $".."

func _ready() -> void:
	if Global.o7:
		foreign.queue_free()
