extends Node
class_name Interactable

@export var prompt = "Interact"
@export var locked_prompt = "Locked"
@export var prompt_input = "interact"
@export var id : String = ""
@export var lock : bool = false
@export var once : bool = false
@export var show_locked_message : bool = false
@export var locked_message : String = ""

func _notification(READY) -> void:
	if READY == NOTIFICATION_READY:
		if id.is_empty():
			if lock or once:
				print("Interactable '" + name + "' has no custom ID set. Lock and once features will be disabled.")
				push_warning("Interactable '" + name + "' has no custom ID set. Lock and once features will be disabled.")
		else:
			if lock:
				InteractableTracker.lock_interactable(id)
			else:
				InteractableTracker.unlock_interactable(id)

func get_prompt() -> String:
	var key_name = ""
	for action in InputMap.action_get_events(prompt_input):
		if action is InputEventKey:
			key_name = action.as_text_physical_keycode()
			break
	
	if not id.is_empty():
		if once and InteractableTracker.has_interacted(id):
			return ""
		if InteractableTracker.is_locked(id):
			return locked_prompt
	
	return prompt + "\n[" + key_name + "]"

func interact(body):
	if not id.is_empty():
		if once and InteractableTracker.has_interacted(id):
			return
		if once:
			InteractableTracker.mark_interacted(id)

func locked(body):
	print(body.name, " tried to interact with locked ", name)

func unlock():
	if id.is_empty():
		print("Cannot unlock '" + name + "': No custom ID set.")
		return
	InteractableTracker.unlock_interactable(id)

func lockObj():
	if id.is_empty():
		push_warning("Cannot lock '" + name + "': No custom ID set.")
		return
	InteractableTracker.lock_interactable(id)
