extends Node3D

@onready var s1: AudioStreamPlayer3D = $ambiance/AudioStreamPlayer3D
@onready var s2: AudioStreamPlayer3D = $ambiance/AudioStreamPlayer3D2
@onready var s3: AudioStreamPlayer3D = $ambiance/AudioStreamPlayer3D3
@onready var s4: AudioStreamPlayer3D = $ambiance/AudioStreamPlayer3D4
@onready var world_env: WorldEnvironment = $"../../../WorldEnvironment"
@onready var player : CharacterBody3D = $"../../../player"

var once = true
var transition_time: float = 2.0
var elapsed_time: float = 0.0
var is_transitioning: bool = false

var initial_fog_density: float = 0.45
var target_fog_density: float = 0.0

var sky_transition_delay: float = 1.0
var sky_elapsed_time: float = -1.0 
var initial_sky_color: Color # 45 55 81 
var target_sky_color: Color = Color(0.12, 0.12, 0.12) 

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and once: 
		is_transitioning = true
		once = false
		elapsed_time = 0.0 
		Global.canSprint = false
		Global.canJump = false
		if world_env.environment and world_env.environment.background_mode == Environment.BG_COLOR:
			initial_sky_color = world_env.environment.background_color
		
		sky_elapsed_time = 0.0  

func _process(delta: float) -> void:
	if is_transitioning:
		elapsed_time += delta
		var t = clamp(elapsed_time / transition_time, 0, 1)
		var new_pitch = lerp(1.0, 0.4, t)
		var new_fog_density = lerp(initial_fog_density, target_fog_density, t)

		s1.pitch_scale = new_pitch
		s2.pitch_scale = new_pitch
		s3.pitch_scale = new_pitch
		s4.pitch_scale = new_pitch

		if world_env.environment:
			world_env.environment.volumetric_fog_density = new_fog_density

		if t >= 1.0:
			is_transitioning = false

	if sky_elapsed_time >= 0.0:
		sky_elapsed_time += delta
		var sky_t = clamp((sky_elapsed_time - sky_transition_delay) / transition_time, 0, 1)

		if world_env.environment and world_env.environment.background_mode == Environment.BG_COLOR:
			world_env.environment.background_color = initial_sky_color.lerp(target_sky_color, sky_t)

		if sky_t >= 1.0:
			sky_elapsed_time = -1.0  
