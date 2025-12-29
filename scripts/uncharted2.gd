extends Npc

@onready var uncharted = $".."

func _ready() -> void:
	if Global.o7:
		uncharted.queue_free()
