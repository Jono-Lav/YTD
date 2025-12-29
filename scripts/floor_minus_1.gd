extends Node3D

@onready var uncharted : AnimationPlayer = $uncharted/StaticBody3D/anim_uncharted
@onready var unchartedCollision : CollisionShape3D = $Uncharted/StaticBody3D/CollisionShape3D
@onready var foreignCollision : CollisionShape3D = $Foreign/StaticBody3D/CollisionShape3D
@onready var player = $player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !Global.o7:
		player.position.x = -32.263
		player.position.y = 29.567
		player.position.z = 6.773

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
