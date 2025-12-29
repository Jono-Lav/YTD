extends Mission

@onready var shaveranim : AnimationPlayer = $TheShaver/AnimationPlayer2
@onready var rotem : AnimationPlayer = $RedReaper/AnimationPlayer2
@onready var rotemInteractableCollision : CollisionShape3D = $RedReaper/StaticBody3D/CollisionShape3D
@onready var TransitionAnim : AnimationPlayer = $Transition

func _ready() -> void:
	TransitionAnim.play("fade_in")
