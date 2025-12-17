extends Mission

@onready var TransitionAnim : AnimationPlayer = $Transition

func _ready() -> void:
	TransitionAnim.play("fade_in")
