extends Node

var interacted_npcs: Dictionary = {}

func save_state():
	var save_data = {}
	for npc_id in interacted_npcs:
		save_data[npc_id] = true
	return save_data

func load_state(save_data: Dictionary):
	interacted_npcs = save_data

func has_interacted(npc_id: String) -> bool:
	return interacted_npcs.has(npc_id)

func mark_interacted(npc_id: String):
	interacted_npcs[npc_id] = true
