extends Node3D

@onready var s1: AudioStreamPlayer3D = $"../ambiance/AudioStreamPlayer3D"
@onready var s2: AudioStreamPlayer3D = $"../ambiance/AudioStreamPlayer3D2"
@onready var s3: AudioStreamPlayer3D = $"../ambiance/AudioStreamPlayer3D3"
@onready var s4: AudioStreamPlayer3D = $"../ambiance/AudioStreamPlayer3D4"
@onready var player : CharacterBody3D = $"../player"

var transition_time: float = 2.0
var is_transitioning: bool = false
var elapsed_time: float = 0.0
var inside : bool = false
var fast : bool = false
var new_pitch

func _ready() -> void:
	if Global.o7:
		queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and !inside: 
		is_transitioning = true
		elapsed_time = 0.0
		inside =  true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D and inside:
		inside = false 
		is_transitioning = true
		elapsed_time = 0.0

func _process(delta: float) -> void:
	if is_transitioning:
		elapsed_time += delta
		var t = clamp(elapsed_time / transition_time, 0, 1)
		if fast:
			new_pitch = lerp(3.4, 1.0, t)
		else:
			new_pitch = lerp(1.0, 3.4, t)
		s1.pitch_scale = new_pitch
		s2.pitch_scale = new_pitch
		s3.pitch_scale = new_pitch
		s4.pitch_scale = new_pitch
		if t >= 1.0:
			is_transitioning = false
			fast = !fast
