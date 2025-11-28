# This script controls the head movement based on the mouse's position.

extends Node3D

# Mouse sensitivity, a low value is recommended for smooth movement
var sense : float = 0.005

# Track if mouse is captured
var mouse_captured : bool = true
var mouse_capturable : bool = true

# Called when the node is ready (initialized)
func _ready():
	# Capture the mouse cursor to prevent it from leaving the screen
	if mouse_capturable:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Handle input events
func _input(event: InputEvent) -> void:
	if mouse_capturable:
		# Handle ESC key press
		if Global.mouse_captured and event.is_action_pressed("ui_cancel"):  # "ui_cancel" is typically mapped to ESC
			toggle_mouse_capture()
		
		# Handle mouse button press to recapture
		if Global.mouse_captured and event is InputEventMouseButton and event.pressed and not mouse_captured:
			set_mouse_captured(true)
		
		# Handle mouse movement only when captured and player isn't stopped
		if event is InputEventMouseMotion and mouse_captured and !Global.playerStop:
			# Rotate the parent node (typically the character or camera) based on mouse movement along the X axis (horizontal)
			get_parent().rotate_y(-event.relative.x * sense)  
			
			# Rotate this node (the camera or head) based on mouse movement along the Y axis (vertical)
			rotate_x(-event.relative.y * sense)
			
			# Clamp the X rotation to prevent the camera from rotating too far up or down
			rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))

# Function to toggle mouse capture state
func toggle_mouse_capture():
	if mouse_capturable:
		mouse_captured = !mouse_captured
		if mouse_captured:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# Function to set mouse capture explicitly
func set_mouse_captured(state: bool):
	if mouse_capturable:
		mouse_captured = state
		if mouse_captured:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta: float) -> void:
	if not Global.mouse_captured and mouse_captured:
		toggle_mouse_capture()
