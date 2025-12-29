extends Node

var trees : Array[Node3D] = []
var history : Array[int] = []
var stop : bool = false
@export var history_size : int = 3 

func _ready() -> void:
	for child in get_children():
		if child is Node3D:
			trees.append(child)

func down():
	if stop or trees.is_empty(): 
		return
	var new_index = randi() % trees.size()
	var actual_history_limit = min(history_size, trees.size() - 1)
	while new_index in history:
		new_index = randi() % trees.size()
	history.append(new_index)
	if history.size() > actual_history_limit:
		history.pop_front() 
	var target_tree = trees[new_index]
	if target_tree.get_child_count() > 0:
		target_tree.get_child(0).down()
	else:
		push_error("Tree at index %d has no children!" % new_index)
