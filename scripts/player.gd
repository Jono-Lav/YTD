extends CharacterBody3D
enum Weapons {NONE, GUN, FIST, SWORD}
@export_group("Attack")
@export var weapon : Weapons = Weapons.NONE
@export_subgroup("Sword")
@export_subgroup("Gun")
@export_subgroup("Fist")
@export_group("Keybinds")
@export var key_left : String = "left"
@export var key_right : String = "right"
@export var key_forward : String = "forward"
@export var key_backward : String = "backward"
@export var key_jump : String = "jump"
@export var key_sprint : String = "run"
@export var key_crouch : String = "crouch"
@export var key_dash : String = "dash"
@export var key_ground_pound : String = "crouch"
@export_group("Settings")
@export var enable_head_bobbing : bool = true
@export var enable_walk_footsteps : bool = true
@export var walk_footsteps : Array[AudioStream]
@export var walk_speed : float = 3.0
@export var jump_height : float = 4.5
@export var mesh_visible : bool = true
@export_group("Abilities")
@export_subgroup("Jump")
@export var enable_jump : bool = true
@export var enable_jump_sound : bool = true
@export var jump_sound : AudioStream
@export var enable_double_jump : bool = true
@export var enable_double_jump_sound : bool = true
@export var double_jump_sound : AudioStream
@export var double_jump_height_percentage : int = 100
@export var double_jump_delay : float = 0.0
@export_subgroup("Sprint")
@export var enable_sprint : bool = true
@export var sprint_speed : float = 7.0
@export_subgroup("Crouch")
@export var enable_crouch : bool = true
@export var crouch_camera_lower_amount : float = 0.5
@export var crouch_lower_hitbox : bool = true
@export var crouch_hitbox_scale : float = 0.5
@export var crouch_speed_multiplier : float = 0.5
@export_subgroup("Slide")
@export var enable_slide : bool = true
@export var enable_slide_sound : bool = true
@export var slide_sound : AudioStream
@export var slide_initial_speed : float = 12.0
@export var slide_duration : float = 1.0
@export var slide_extra_lower_amount : float = 0.3
@export var slide_lock_percentage : int = 100
@export var slide_camera_tilt_angle : float = 5.0
@export_subgroup("Flight")
@export var enable_flight : bool = true
@export var flight_speed : float = 10.0
@export_subgroup("Dash")
@export var enable_dash : bool = true
@export var enable_dash_sound : bool = true
@export var dash_sound : AudioStream
@export var dash_cooldown : float = 1.0
@export var dash_speed : float = 15.0
@export var dash_duration : float = 0.5
@export var dash_in_look_direction : bool = false
@export_subgroup("Ground Pound")
@export var enable_ground_pound : bool = true
@export var enable_ground_pound_sound : bool = true
@export var ground_pound_sound : AudioStream
@export var ground_pound_speed : float = 20.0
@export var min_height_for_pound : float = 1.0
@export var enable_shake : bool = true
@export var shake_intensity : float = 0.1
@export var shake_duration : float = 0.2
@export_subgroup("Landing")
@export var enable_soft_land_sound : bool = true
@export var soft_land_sound : AudioStream
@export var enable_hard_land_sound : bool = true
@export var hard_land_sound : AudioStream
@export var min_land_drop_for_sound : float = 0.5
@export var hard_land_threshold : float = 5.0
@export_subgroup("Wallrun")
@export var enable_wallrun : bool = true
@export var wallrun_speed : float = 10.0
@export var wallrun_gravity_multiplier : float = 0.5
@export var wallrun_attraction : float = 2.0
@export var wall_check_distance : float = 1.0
@export var enable_wallrun_camera_tilt : bool = true
@export var wallrun_camera_tilt_intensity : float = 15.0
const HEAD_BOB_WALKING_SPEED : float = 10.0
const HEAD_BOB_SPRINTING_SPEED : float = 20.0
const HEAD_BOB_INTENSITY : float = 0.03
@onready var footstep_player : AudioStreamPlayer3D = $FootStepSound
@onready var camera : Camera3D = $head/Camera3D
@onready var score : RichTextLabel = $UI/score
@onready var anim : AnimationPlayer = $UI/UIAnimations
@onready var head : Node3D = $head
@onready var default_collision : CollisionShape3D = $DefaultCollision
@onready var crouch_collision : CollisionShape3D = $CrouchCollision
@onready var slide_collision : CollisionShape3D = $SlideCollision
@onready var ground_ray : RayCast3D = $GroundRay
@onready var left_wall_ray : RayCast3D = $LeftWallRay
@onready var right_wall_ray : RayCast3D = $RightWallRay
@onready var mesh_instance : MeshInstance3D = $MeshInstance3D
var head_bob_offset : Vector2 = Vector2.ZERO
var rng : RandomNumberGenerator
var sprinting : bool = false
var crouching : bool = false
var sliding : bool = false
var flying : bool = false
var dashing : bool = false
var ground_pounding : bool = false
var wallrunning : bool = false
var wall_side : int = 0  # -1 left, 1 right
var wall_normal : Vector3 = Vector3.ZERO
var slide_timer : float = 0.0
var dash_timer : float = 0.0
var dash_cooldown_timer : float = 0.0
var shake_timer : float = 0.0
var slide_vector : Vector2 = Vector2.ZERO
var dash_direction : Vector3 = Vector3.ZERO
var slide_camera_tilt_direction : float = 1.0
var footstep_timer : float = 0.0
var footstep_interval : float = 0.5
var head_bob_intensity : float = 0.0
var speed : float
var head_bob_index : float = 0.0
var sprint_slider_max_value : int = 1
var max_jumps : int = 2
var jumps_remaining : int = 0
var double_jump_timer : float = 0.0
var has_jumped_once : bool = false
var original_head_y : float = 0.0
var original_collision_height : float = 0.0
var original_collision_y : float = 0.0
var current_camera_tilt : float = 0.0
var wallrun_camera_tilt : float = 0.0
var camera_shake_offset : Vector3 = Vector3.ZERO
var was_on_floor : bool = false
var air_max_y : float = 0.0
func _ready() -> void:
	rng = RandomNumberGenerator.new()
	speed = walk_speed
	score.text = "[wave freq=3.5 height=0][shake freq=1.0 width=10 height=10][b]"+str(Global.score)+"[/b][/shake][/wave]"
	original_head_y = head.position.y
	if default_collision and default_collision.shape is CapsuleShape3D:
		original_collision_height = default_collision.shape.height
		original_collision_y = default_collision.position.y
	elif default_collision and default_collision.shape is BoxShape3D:
		original_collision_height = default_collision.shape.size.y
		original_collision_y = default_collision.position.y
	max_jumps = 2 if enable_double_jump else 1
	if mesh_instance:
		mesh_instance.visible = mesh_visible
	if crouch_collision:
		crouch_collision.disabled = true
	if slide_collision:
		slide_collision.disabled = true
	if left_wall_ray:
		left_wall_ray.target_position = Vector3(-wall_check_distance, 0, 0)
	if right_wall_ray:
		right_wall_ray.target_position = Vector3(wall_check_distance, 0, 0)
	air_max_y = position.y
func _process(delta: float) -> void:
	_handle_sprinting(delta)
	_handle_crouching(delta)
	_handle_sliding(delta)
	_handle_flying(delta)
	_handle_dashing(delta)
	_handle_ground_pound(delta)
	_handle_wallrunning(delta)
	_handle_camera_shake(delta)
	_handle_head_position(delta)
	_handle_collisions()
	_handle_camera_tilt(delta)
	if mesh_instance:
		mesh_instance.visible = mesh_visible
func scoreUpdate(time : float = 0.7) -> void:
	await get_tree().create_timer(time).timeout
	anim.play("scoreUpdate")
	score.text = "[wave freq=3.5 height=0][shake freq=1.0 width=10 height=10][b]"+str(Global.score)+"[/b][/shake][/wave]"
func _physics_process(delta: float) -> void:
	if not is_on_floor() and not flying and not ground_pounding and not wallrunning:
		velocity += get_gravity() * delta
		air_max_y = max(air_max_y, position.y)
	if is_on_floor():
		jumps_remaining = max_jumps
		has_jumped_once = false
		double_jump_timer = 0.0
		if flying:
			_end_flight()
		if ground_pounding:
			_end_ground_pound()
		if wallrunning:
			_end_wallrun()
		if not was_on_floor and not ground_pounding and not flying:
			var drop_height = air_max_y - position.y
			if drop_height > min_land_drop_for_sound:
				if drop_height > hard_land_threshold and enable_hard_land_sound and hard_land_sound:
					_play_sound(hard_land_sound)
				elif enable_soft_land_sound and soft_land_sound:
					_play_sound(soft_land_sound)
		air_max_y = position.y
	if not is_on_floor() and has_jumped_once:
		double_jump_timer += delta
	if Input.is_action_just_pressed(key_jump) and !Global.playerStop and Global.canJump and enable_jump and not sliding and not dashing and not ground_pounding and not wallrunning:
		if jumps_remaining > 0:
			var effective_velocity = jump_height
			if jumps_remaining < max_jumps:
				if double_jump_timer >= double_jump_delay:
					effective_velocity = jump_height * (double_jump_height_percentage / 100.0)
					if enable_double_jump_sound and double_jump_sound:
						_play_sound(double_jump_sound)
				else:
					return
			else:
				if enable_jump_sound and jump_sound:
					_play_sound(jump_sound)
			velocity.y = effective_velocity
			jumps_remaining -= 1
			if jumps_remaining == max_jumps - 1:
				has_jumped_once = true
	elif not is_on_floor() and enable_flight and not flying:
		_start_flight()
	var input_direction := Input.get_vector(key_left, key_right, key_forward, key_backward)
	var move_direction := (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	if (move_direction and !Global.playerStop) and not sliding and not dashing and not wallrunning:
		_move_character(move_direction, delta)
		if enable_head_bobbing:
			_update_head_bob(delta)
		if enable_walk_footsteps:
			_play_footstep_sounds(delta)
	elif sliding:
		_apply_slide_movement(delta)
		if enable_head_bobbing:
			_update_head_bob(delta)
	elif dashing:
		_apply_dash_movement(delta)
		if enable_head_bobbing:
			_update_head_bob(delta)
	elif wallrunning:
		_apply_wallrun_movement(delta)
		if enable_head_bobbing:
			_update_head_bob(delta)
		if enable_walk_footsteps:
			_play_footstep_sounds(delta)
	else:
		_apply_friction(delta)
	if ground_pounding:
		velocity.y = -ground_pound_speed
		if move_direction and !Global.playerStop:
			_move_character(move_direction, delta)
	was_on_floor = is_on_floor()
	move_and_slide()
func _handle_sprinting(delta: float) -> void:
	if not enable_sprint or not Global.canSprint:
		return
	if Input.is_action_just_pressed(key_sprint):
		sprinting = true
		print("Sprint attempt, sprinting:", sprinting, "canSprint:", Global.canSprint, "enable_sprint:", enable_sprint)
	if Input.is_action_just_released(key_sprint):
		sprinting = false
	if sprinting:
		head_bob_intensity = HEAD_BOB_INTENSITY * 4
		head_bob_index += HEAD_BOB_SPRINTING_SPEED * delta
		footstep_interval = 0.2
		footstep_player.volume_db = -40
	else:
		head_bob_intensity = HEAD_BOB_INTENSITY * 2
		head_bob_index += HEAD_BOB_WALKING_SPEED * delta
		footstep_interval = 0.5
		footstep_player.volume_db = -45
func _handle_crouching(delta: float) -> void:
	if not enable_crouch or sliding or flying or dashing or ground_pounding or wallrunning:
		return
	crouching = Input.is_action_pressed(key_crouch)
	if crouching:
		footstep_interval = 0.6
		footstep_player.volume_db = -50
func _handle_sliding(delta: float) -> void:
	if not enable_slide or not is_on_floor() or flying or dashing or ground_pounding or wallrunning:
		return
	var input_direction := Input.get_vector(key_left, key_right, key_forward, key_backward)
	if Input.is_action_pressed(key_sprint) and Input.is_action_just_pressed(key_crouch) and input_direction != Vector2.ZERO and not sliding:
		print("Slide attempt, sprint pressed:", Input.is_action_pressed(key_sprint), "crouch just pressed:", Input.is_action_just_pressed(key_crouch), "input direction:", input_direction)
		_start_slide(input_direction)
	if not sliding:
		return
	slide_timer -= delta
	if slide_timer <= 0:
		_end_slide()
		return
	var tilt_progress = sin((1.0 - slide_timer / slide_duration) * PI)
	var target_tilt = slide_camera_tilt_angle * slide_camera_tilt_direction * tilt_progress
	current_camera_tilt = lerp(current_camera_tilt, target_tilt, delta * 10)
	footstep_interval = 0.15
	footstep_player.volume_db = -35
	var lock_time = (slide_lock_percentage / 100.0) * slide_duration
	print("Slide update, timer:", slide_timer, "lock_time:", lock_time, "sliding:", sliding, "head y:", head.position.y)
	if slide_timer > 0 and lock_time < slide_duration:
		if Input.is_action_just_pressed(key_left) or Input.is_action_just_pressed(key_right) or Input.is_action_just_pressed(key_forward) or Input.is_action_just_pressed(key_backward):
			_end_slide()
func _handle_flying(delta: float) -> void:
	if not flying:
		return
	var vertical_input = 0.0
	if Input.is_action_pressed(key_jump):
		vertical_input += 1.0
	if Input.is_action_pressed(key_crouch):
		vertical_input -= 1.0
	var input_direction := Input.get_vector(key_left, key_right, key_forward, key_backward)
	var move_direction := (transform.basis * Vector3(input_direction.x, vertical_input, input_direction.y)).normalized()
	velocity = move_direction * flight_speed
	head_bob_intensity = HEAD_BOB_INTENSITY * 2
	head_bob_index += HEAD_BOB_WALKING_SPEED * delta
	footstep_interval = 0.5
	footstep_player.volume_db = -45
func _handle_dashing(delta: float) -> void:
	if not enable_dash or sliding or flying or ground_pounding or wallrunning:
		return
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	if Input.is_action_just_pressed(key_dash) and dash_cooldown_timer <= 0 and not dashing:
		_start_dash()
	if not dashing:
		return
	dash_timer += delta
	if dash_timer >= dash_duration:
		_end_dash()
		return
func _handle_ground_pound(delta: float) -> void:
	if not enable_ground_pound or is_on_floor() or sliding or flying or dashing or ground_pounding or wallrunning:
		return
	if Input.is_action_just_pressed(key_ground_pound) and _get_ground_distance() > min_height_for_pound:
		_start_ground_pound()
func _handle_wallrunning(delta: float) -> void:
	if not enable_wallrun or is_on_floor() or flying or dashing or ground_pounding or sliding:
		return
	if wallrunning:
		var active_ray = left_wall_ray if wall_side == -1 else right_wall_ray
		if not active_ray.is_colliding() or not Input.is_action_pressed(key_sprint) or Input.is_action_just_pressed(key_jump) or Input.is_action_just_pressed(key_crouch) or Input.is_action_just_pressed(key_dash) or Input.is_action_just_pressed(key_ground_pound):
			_end_wallrun()
		return
	if Input.is_action_pressed(key_sprint):
		var wall_detected = false
		var detected_side = 0
		var detected_normal = Vector3.ZERO
		if left_wall_ray.is_colliding():
			detected_normal = left_wall_ray.get_collision_normal().normalized()
			if detected_normal.y <= 0:
				wall_detected = true
				detected_side = -1
		elif right_wall_ray.is_colliding():
			detected_normal = right_wall_ray.get_collision_normal().normalized()
			if detected_normal.y <= 0:
				wall_detected = true
				detected_side = 1
		if wall_detected:
			_start_wallrun(detected_side, detected_normal)
func _handle_camera_shake(delta: float) -> void:
	if shake_timer > 0:
		shake_timer -= delta
		camera_shake_offset = Vector3(rng.randf_range(-shake_intensity, shake_intensity), rng.randf_range(-shake_intensity, shake_intensity), 0)
		camera.position += camera_shake_offset
	else:
		camera.position -= camera_shake_offset
		camera_shake_offset = Vector3.ZERO
func _handle_head_position(delta: float) -> void:
	var target_head_y = original_head_y
	if sliding:
		target_head_y -= crouch_camera_lower_amount + slide_extra_lower_amount
	elif crouching:
		target_head_y -= crouch_camera_lower_amount
	head.position.y = lerp(head.position.y, target_head_y, delta * 10)
func _handle_collisions() -> void:
	if sliding:
		default_collision.disabled = true
		crouch_collision.disabled = true
		slide_collision.disabled = false
	elif crouching:
		default_collision.disabled = true
		crouch_collision.disabled = false
		slide_collision.disabled = true
	else:
		default_collision.disabled = false
		crouch_collision.disabled = true
		slide_collision.disabled = true
func _handle_camera_tilt(delta: float) -> void:
	if sliding:
		camera.rotation_degrees.z = current_camera_tilt
	elif wallrunning and enable_wallrun_camera_tilt:
		var target_wallrun_tilt = wallrun_camera_tilt_intensity * -wall_side  # Adjust sign based on desired tilt direction
		wallrun_camera_tilt = lerp(wallrun_camera_tilt, target_wallrun_tilt, delta * 10)
		camera.rotation_degrees.z = wallrun_camera_tilt
	else:
		current_camera_tilt = lerp(current_camera_tilt, 0.0, delta * 10)
		wallrun_camera_tilt = lerp(wallrun_camera_tilt, 0.0, delta * 10)
		camera.rotation_degrees.z = 0.0
func _start_slide(input_dir: Vector2) -> void:
	sliding = true
	crouching = true
	sprinting = false
	slide_timer = slide_duration
	slide_vector = input_dir
	slide_camera_tilt_direction = 1.0 if rng.randf() > 0.5 else -1.0
	velocity.x = (transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized().x * slide_initial_speed
	velocity.z = (transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized().z * slide_initial_speed
	print("Slide started, velocity:", velocity, "sliding:", sliding, "vector:", slide_vector)
	if enable_slide_sound and slide_sound:
		_play_sound(slide_sound)
func _end_slide() -> void:
	sliding = false
	slide_timer = 0.0
	current_camera_tilt = 0.0
	if not Input.is_action_pressed(key_crouch):
		crouching = false
	if Input.is_action_pressed(key_sprint):
		sprinting = true
	print("Slide ended, velocity:", velocity, "sliding:", sliding, "reason: timer or input")
func _start_flight() -> void:
	flying = true
	velocity.y = 0.0
func _end_flight() -> void:
	flying = false
func _start_dash() -> void:
	dashing = true
	dash_timer = 0.0
	if dash_in_look_direction:
		dash_direction = -camera.global_transform.basis.z.normalized()
	else:
		dash_direction = -transform.basis.z.normalized()
	dash_direction.y = 0
	dash_direction = dash_direction.normalized()
	dash_cooldown_timer = dash_cooldown
	if enable_dash_sound and dash_sound:
		_play_sound(dash_sound)
func _end_dash() -> void:
	dashing = false
	dash_timer = 0.0
	if Input.is_action_pressed(key_sprint) and enable_sprint and Global.canSprint:
		sprinting = true
func _start_ground_pound() -> void:
	ground_pounding = true
	velocity.y = -ground_pound_speed
func _end_ground_pound() -> void:
	ground_pounding = false
	if enable_shake:
		shake_timer = shake_duration
	if enable_ground_pound_sound and ground_pound_sound:
		_play_sound(ground_pound_sound)
func _start_wallrun(side: int, normal: Vector3) -> void:
	wallrunning = true
	wall_side = side
	wall_normal = normal
	velocity.y = 0.0  # Optional: reset vertical velocity on start
func _end_wallrun() -> void:
	wallrunning = false
	wall_side = 0
	wall_normal = Vector3.ZERO
func _apply_slide_movement(delta: float) -> void:
	var speed_factor = slide_timer / slide_duration
	var current_speed = slide_initial_speed * speed_factor
	velocity.x = (transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized().x * current_speed
	velocity.z = (transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized().z * current_speed
	print("Slide moving, velocity:", velocity, "timer:", slide_timer, "speed_factor:", speed_factor)
func _apply_dash_movement(delta: float) -> void:
	var speed_factor = 1.0 - (dash_timer / dash_duration)
	var current_speed = dash_speed * speed_factor
	velocity = dash_direction * current_speed
func _apply_wallrun_movement(delta: float) -> void:
	velocity += get_gravity() * wallrun_gravity_multiplier * delta
	var forward = -transform.basis.z.normalized()
	var wall_tangent = (forward - forward.project(wall_normal)).normalized()
	velocity.x = wall_tangent.x * wallrun_speed
	velocity.z = wall_tangent.z * wallrun_speed
	velocity -= wall_normal * wallrun_attraction  # Attract towards wall
func _get_ground_distance() -> float:
	if ground_ray.is_colliding():
		return global_position.distance_to(ground_ray.get_collision_point())
	return 0.0
func _update_head_bob(delta: float) -> void:
	if (is_on_floor() or wallrunning) and enable_head_bobbing:
		head_bob_offset.y = sin(head_bob_index)
		head_bob_offset.x = sin(head_bob_index / 2) + 0.5
		camera.position.y = lerp(camera.position.y, head_bob_offset.y * (head_bob_intensity / 2), delta * 10)
		camera.position.x = lerp(camera.position.x, head_bob_offset.x * head_bob_intensity, delta * 10)
func _play_footstep_sounds(delta: float) -> void:
	if (is_on_floor() or wallrunning) and not footstep_player.playing and enable_walk_footsteps:
		footstep_timer += delta
		if footstep_timer >= footstep_interval:
			footstep_player.stream = walk_footsteps[rng.randi_range(0, walk_footsteps.size() - 1)]
			footstep_player.play()
			footstep_timer = 0.0
func _move_character(direction: Vector3, _delta: float) -> void:
	if sliding:
		return
	speed = walk_speed
	if sprinting:
		speed = sprint_speed
	if crouching:
		speed *= crouch_speed_multiplier
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
func _apply_friction(_delta: float) -> void:
	if sliding:
		return
	velocity.x = move_toward(velocity.x, 0, speed)
	velocity.z = move_toward(velocity.z, 0, speed)
func _play_sound(stream: AudioStream) -> void:
	if not stream:
		return
	var player = AudioStreamPlayer3D.new()
	player.stream = stream
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
