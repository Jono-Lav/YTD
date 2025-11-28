extends Interactable

var nametag : Label3D
var player : CharacterBody3D
@onready var root : Node3D = $".."

func _ready() -> void:
	player = get_node("/root/" + get_tree().current_scene.name + "/player")
	nametag = Label3D.new()
	nametag.text = get_parent().name
	nametag.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	nametag.pixel_size = 0.006
	nametag.visible = true
	get_parent().add_child(nametag)
	set_process(true)

func _process(delta: float) -> void:
	if nametag:
		update_nametag_position()

func get_highest_point() -> Vector3:
	var base_pos = get_parent().global_position
	return base_pos + Vector3(0, 2.3, 0)

func update_nametag_position():
	if not nametag:
		return
	if not get_parent().is_inside_tree():
		return
	if not nametag.is_inside_tree():
		if nametag.get_parent() != get_parent():
			get_parent().add_child(nametag)
		return
	var highest_point = get_highest_point()
	nametag.global_position = highest_point + Vector3(0, 0.3, 0)

func interact(body):
	player = get_node("/root/" + get_tree().current_scene.name + "/player")
	var direction = player.global_transform.origin - root.global_transform.origin
	direction.y = 0  
	var new_transform = Transform3D.IDENTITY.looking_at(direction, Vector3.UP)
	var current_scale = root.scale
	root.global_transform = Transform3D(new_transform.basis, root.global_transform.origin)
	root.scale = current_scale
	if get_tree().current_scene.name == "floor_1" && Global.dialugefinishedo6:
		DialogueManager.show_example_dialogue_balloon(load("res://dialogue/rotem2.dialogue"))
	elif get_tree().current_scene.name == "floor_1":
		DialogueManager.show_example_dialogue_balloon(load("res://dialogue/rotem.dialogue"))
	elif get_tree().current_scene.name == "WorldOfTheRedReaper":
		DialogueManager.show_example_dialogue_balloon(load("res://dialogue/rotem3.dialogue"))
