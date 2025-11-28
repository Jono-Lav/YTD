extends RichTextLabel
#
#@onready var camera = $"../../Camera3D"
#
#func _ready():
	#await get_tree().process_frame
	#if camera:
		#print("Camera found: ", camera)
	#else:
		#print("Error: Camera not found at ../../Camera3D")
#
#func _process(delta):
	#var label_screen_pos = _get_screen_position()
	#print("Label screen position: ", label_screen_pos)
	#if label_screen_pos == Vector2():
		#print("Invalid screen position")
		#return
#
	#var ray_origin = camera.project_ray_origin(label_screen_ pos)
	#var ray_direction = camera.project_ray_normal(label_screen_pos)
	#var space_state = get_viewport().get_world_3d().direct_space_state
	#var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_direction * 1000)
	#query.exclude = [get_parent()]
	#var result = space_state.intersect_ray(query)
#
	#if result:
		#print("Raycast hit: ", result.collider)
		#var collider = result.collider
		#var mesh_instance = null
		#
		#if collider is StaticBody3D or collider is RigidBody3D or collider is CharacterBody3D:
			#for child in collider.get_children():
				#if child is MeshInstance3D:
					#mesh_instance = child
					#print("Found MeshInstance3D: ", mesh_instance)
					#break
		#
		#if mesh_instance:
			#var material = mesh_instance.get_active_material(0)
			#print("Material: ", material)
			#if material and material is StandardMaterial3D:
				#var bg_color = material.albedo_color
				#print("Background color: ", bg_color)
				#var inverted_color = Color(1.0 - bg_color.r, 1.0 - bg_color.g, 1.0 - bg_color.b, bg_color.a)
				#print("Inverted color: ", inverted_color)
				#var color_hex = inverted_color.to_html(false)
				#text = "[color=#" + color_hex + "]" + getText() + "[/color]"
				#print("Text updated to: ", text)
			#else:
				#print("No valid StandardMaterial3D found")
		#else:
			#print("No MeshInstance3D found")
#
#func _get_screen_position() -> Vector2:
	#return global_position + size / 2
#
#func getText() -> String:
	#var regex = RegEx.new()
	#regex.compile("\\[.*?\\]")
	#return regex.sub(text, "", true)
