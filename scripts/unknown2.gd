extends Npc

@onready var unknown = $".."

func _ready() -> void:
	if Global.o7:
		unknown.queue_free()
