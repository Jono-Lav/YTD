@tool
extends EditorInspectorPlugin

var editor_interface : EditorInterface

func _init(p_editor_interface : EditorInterface) -> void:
	if p_editor_interface:
		editor_interface = p_editor_interface

func _can_handle(object: Object) -> bool:
	return object is Enemy

func _parse_begin(object: Object) -> void:
	if object is Enemy:
		var panel = PanelContainer.new()
		var vbox = VBoxContainer.new()
		panel.add_child(vbox)
		
		if object.shooting:
			var add_shooting_button = Button.new()
			add_shooting_button.text = "Add Shooting Point"
			add_shooting_button.connect("pressed", Callable(self, "_on_add_shooting_point_pressed").bind(object))
			vbox.add_child(add_shooting_button)
		
		if object.danger_zone:
			var add_danger_button = Button.new()
			add_danger_button.text = "Add Danger Zone"
			add_danger_button.connect("pressed", Callable(self, "_on_add_danger_zone_pressed").bind(object))
			vbox.add_child(add_danger_button)
		
		if vbox.get_child_count() > 0:  
			add_custom_control(panel)

func _on_add_shooting_point_pressed(enemy : Node) -> void:
	var point = ShootingPoint.new()
	point.name = "ShootingPoint_" + str(enemy.get_child_count())
	enemy.add_child(point)
	point.owner = enemy.owner
	if editor_interface:
		editor_interface.get_selection().clear()
		editor_interface.get_selection().add_node(point)

func _on_add_danger_zone_pressed(danger_zone : Node) -> void:
	var zone = DangerZone.new()
	zone.name = "DangerZone_" + str(danger_zone.get_child_count())
	danger_zone.add_child(zone)
	zone.owner = danger_zone.owner
	if editor_interface:
		editor_interface.get_selection().clear()
		editor_interface.get_selection().add_node(zone)
