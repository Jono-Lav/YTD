extends RayCast3D

@onready var prompt : RichTextLabel = $prompt
@onready var lockedMessage : RichTextLabel = $"../../UI/lockedMessage"

func _physics_process(delta):
	if is_colliding():
		var collider = get_collider()
		if collider is Npc or collider is Interactable:
			prompt.text = "[shake freq=1.0 width=10 height=10]" + collider.get_prompt() + "[/shake]"
			if Input.is_action_just_pressed(collider.prompt_input):
				if collider is Interactable:
					if !collider.lock:
						collider.interact(owner)
					elif !collider.id.is_empty():
						collider.locked(owner)
						if collider.show_locked_message:
							lockedMessage.visible = true
							await get_tree().create_timer(2.0).timeout
							lockedMessage.visible = false
				else:
					collider.dialog()
					collider.interact(owner)
		else:
			prompt.text = ""
	else:
		prompt.text = ""
