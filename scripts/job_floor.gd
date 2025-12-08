extends Node3D

@onready var ovalAnim : AnimationPlayer = $oval/StaticBody3D/AnimationPlayer2
@onready var paper : StaticBody3D = $Paper
@onready var textedit = $oval/StaticBody3D/paper/TextEdit
@onready var signaturelines = $SignatureLines
@onready var ovalCollision : CollisionShape3D = $oval/StaticBody3D/CollisionShape3D
@onready var animation : AnimationPlayer = $"fade out"

var done : bool = false

func _ready() -> void:
	animation.play("fadeout")
