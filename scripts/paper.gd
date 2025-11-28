extends Node2D

@onready var paper: Sprite2D = $PaperTexture
@onready var signatureLines: Node2D = $SignatureLines
@onready var writing_sound: AudioStreamPlayer = $WritingSound
@onready var clearButton: Sprite2D = $clear
@onready var sendButton : Sprite2D = $send

@onready var rootNode : Node3D = get_node("/root/" + get_tree().current_scene.name)
@onready var player : Node3D = get_node("/root/" + get_tree().current_scene.name + "/player/head")

var is_drawing = false
var current_line: Line2D = null
var last_point: Vector2 = Vector2.ZERO
var was_moving: bool = false

func _ready():
	writing_sound.stream.loop = false

func is_mouse_on_sprite(mouse_pos: Vector2, sprite : Sprite2D) -> bool:
	var texture = sprite.texture
	if texture == null: 
		return false
	
	var sprite_size = texture.get_size() * sprite.scale
	var sprite_pos = sprite.global_position - (sprite_size / 2)
	
	var sprite_rect = Rect2(sprite_pos, sprite_size)
	
	return sprite_rect.has_point(mouse_pos)

func _process(delta):
	if is_drawing:
		var mouse_pos = get_global_mouse_position()
		if is_mouse_on_sprite(mouse_pos, paper):
			if last_point.distance_to(mouse_pos) > 2:
				current_line.add_point(mouse_pos)
				last_point = mouse_pos
				
				if not writing_sound.playing:
					writing_sound.play()
					was_moving = true
			else:
				if was_moving and writing_sound.playing:
					writing_sound.stop()
					was_moving = false
		else:
			if writing_sound.playing:
				writing_sound.stop()
			was_moving = false

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		if event.pressed:
			
			if is_mouse_on_sprite(mouse_pos, clearButton):
				clear_signature()
			
			elif is_mouse_on_sprite(mouse_pos, sendButton):
				if signatureLines.get_child_count() != 0:
					rootNode.done = true
					visible = false
					player.mouse_capturable = true
					player.toggle_mouse_capture()
					Global.playerStop = false
					rootNode.ovalCollision.disabled = false
				else:
					DialogueManager.show_example_dialogue_balloon(load("res://dialogue/ovalSIGNTHIS.dialogue"))
			
			elif is_mouse_on_sprite(mouse_pos, paper):
				is_drawing = true
				current_line = Line2D.new()
				current_line.width = 2.0
				current_line.default_color = Color.BLACK
				signatureLines.add_child(current_line)
				last_point = mouse_pos
				current_line.add_point(last_point)
		else:
			is_drawing = false
			writing_sound.stop()
			was_moving = false

func clear_signature():
	for child in signatureLines.get_children():
		child.queue_free()
