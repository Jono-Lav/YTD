extends Node

var interacted_interactables: Dictionary = {}
var locked_interactables: Dictionary = {}

func save_state() -> Dictionary:
	var save_data = {
		"interacted": interacted_interactables.duplicate(),
		"locked": locked_interactables.duplicate()
	}
	return save_data

func load_state(save_data: Dictionary):
	if save_data.has("interacted"):
		interacted_interactables = save_data["interacted"]
	if save_data.has("locked"):
		locked_interactables = save_data["locked"]

func has_interacted(interactable_id: String) -> bool:
	return interacted_interactables.has(interactable_id)

func mark_interacted(interactable_id: String):
	interacted_interactables[interactable_id] = true

func is_locked(interactable_id: String) -> bool:
	return locked_interactables.has(interactable_id) and locked_interactables[interactable_id]

func lock_interactable(interactable_id: String):
	locked_interactables[interactable_id] = true

func unlock_interactable(interactable_id: String):
	if locked_interactables.has(interactable_id):
		locked_interactables[interactable_id] = false
	else:
		locked_interactables.erase(interactable_id)  

func get_locked_interactables() -> Dictionary:
	return locked_interactables.duplicate()
