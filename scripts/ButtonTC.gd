extends Interactable

signal pressed(value : int)
signal buttonLocked(value : int)

@onready var root = $"../../../../../.."

func _ready() -> void:
	connect("pressed", root._on_pressed)
	connect("buttonLocked", root._on_locked)

func interact(body):
	emit_signal("pressed", 2)

func locked(body):
	emit_signal("buttonLocked", 2)
