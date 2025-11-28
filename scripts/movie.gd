extends Node2D

@onready var video = $VideoStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1.5).timeout
	video.play()
	await get_tree().create_timer(5.0).timeout
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Button.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	video.paused = !video.paused
