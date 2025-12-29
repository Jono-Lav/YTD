extends Npc

@onready var remote = $".."

func _ready() -> void:
	if Global.o7:
		remote.queue_free()
