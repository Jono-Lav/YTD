extends Node
class_name Npc

@export var prompt_message : String = "TALK"
@export var prompt_input : String = "interact"
@export var dialogue : DialogueResource
@export var turn_talk : bool = false
@export var turn_opposite : bool = false
@export var free_talk : bool = false
@export var play_once : bool = false
@export var show_nametag : bool = false : set = set_show_nametag

@onready var player : CharacterBody3D = get_node("/root/" + get_tree().current_scene.name + "/player")
@onready var id : String = get_path()

var collision : CollisionShape3D
var anim : AnimationPlayer
var idle_anim : String = ""
var talk_anim : String = ""
var npc_name : String = ""
var nametag : Label3D

func _ready() -> void:
	if npc_name.is_empty():
		npc_name = get_parent().name if not get_parent() == get_tree().current_scene or get_parent().get_child_count() > 1 else name
	
	collision = find(self, "CollisionShape3D")
	anim = find(self, "AnimationPlayer")
	
	if anim:
		for anim_name in anim.get_animation_list():
			if "idle" in anim_name.to_lower():
				idle_anim = anim_name
				anim.get_animation(idle_anim).loop = true
				anim.play(idle_anim)
			elif "talk" in anim_name.to_lower():
				talk_anim = anim_name
				anim.get_animation(talk_anim).loop = true

	nametag = Label3D.new()
	nametag.text = npc_name
	nametag.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	nametag.pixel_size = 0.006
	nametag.visible = show_nametag
	get_parent().add_child(nametag)
	set_process(true)

func get_highest_point() -> Vector3:
	var base_pos = get_parent().global_position
	return base_pos + Vector3(0, 2.0, 0)

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

func _process(delta: float) -> void:
	if nametag:
		nametag.visible = show_nametag
		if show_nametag:
			update_nametag_position()

func set_show_nametag(value: bool) -> void:
	show_nametag = value
	if nametag and nametag.is_inside_tree():
		nametag.visible = value
		if value:
			update_nametag_position()

func find(parent: Node, type : String) -> Variant:
	for child in parent.get_children():
		if child.get_class() == type:
			return child
		if child.get_child_count() > 0:
			var found = find(child, type)
			if found:
				return found
	return null

func get_prompt():
	if play_once and NpcTracker.has_interacted(id):
		return ""
	var key_name = ""
	for action in InputMap.action_get_events(prompt_input):
		if action is InputEventKey:
			key_name = action.as_text_physical_keycode()
			break
	if "[name]" in prompt_message:
		if not npc_name.is_empty():
			prompt_message = prompt_message.replace("[name]", npc_name)
		else:
			prompt_message = "Interact"
	return prompt_message + "\n[" + key_name + "]"

func dialog():
	if play_once and NpcTracker.has_interacted(id):
		return
	if dialogue:
		Global.playerStop = false if free_talk else true
		if turn_talk:
			var direction = player.global_transform.origin - get_parent().global_transform.origin
			direction.y = 0
			var direc = direction if not turn_opposite else -direction
			var new_transform = Transform3D.IDENTITY.looking_at(direc, Vector3.UP)
			var current_scale = get_parent().scale
			get_parent().global_transform = Transform3D(new_transform.basis, get_parent().global_transform.origin)
			get_parent().scale = current_scale
		collision.disabled = true
		if talk_anim:
			anim.play("talk")
		DialogueManager.show_example_dialogue_balloon(dialogue)
		await DialogueManager.dialogue_ended
		collision.disabled = false
		Global.playerStop = false
		if anim:
			anim.play(idle_anim if idle_anim else "RESET")
		if play_once:
			NpcTracker.mark_interacted(id)
	else:
		print("No dialogue resource assigned to ", name)

func interact(body):
	print(body.name, " interacted with ", name)
