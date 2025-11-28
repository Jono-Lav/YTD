class_name Player extends CharacterBody2D

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
@onready var pickupsound : AudioStreamPlayer = $AudioStreamPlayer2D

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
var speed : float = 100.0
var state : String = "none"
var is_walking : bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("left"):
		state = "left"
		$AnimatedSprite2D.animation = "walk left"
		anim.play("walk_left")
		$AnimatedSprite2D.visible = true
	elif Input.is_action_pressed("right"):
		state = "right"
		$AnimatedSprite2D.animation = "walk right"
		anim.play("walk_right")
		$AnimatedSprite2D.visible = true
	elif Input.is_action_pressed("backward"):
		state = "down"
		$AnimatedSprite2D.animation = "walk down"
		anim.play("walk_down")
		$AnimatedSprite2D.visible = true
	elif Input.is_action_pressed("forward"):
		state = "up"
		$AnimatedSprite2D.animation = "walk up"
		anim.play("walk_up")
		$AnimatedSprite2D.visible = true
	elif Input.is_action_just_released("backward") or Input.is_action_just_released("forward") or Input.is_action_just_released("right") or Input.is_action_just_pressed("left"):
		state = "idle"

func _process(delta: float) -> void:
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	if anim.is_playing() and !Input.is_action_pressed("forward") and !Input.is_action_pressed("backward") and !Input.is_action_pressed("right") and !Input.is_action_pressed("left"):
		anim.stop()
	velocity = direction * speed
	$Label.text = str(Global.score2d) + "/5"
	pass

func _physics_process(delta: float) -> void:
	move_and_slide()
