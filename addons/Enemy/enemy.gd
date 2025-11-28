@tool
extends Node3D
class_name Enemy

@export var debug : bool = false
@export_group("Attack type")
@export var shooting : bool = false:
	set(value):
		shooting = value
		if Engine.is_editor_hint() and not value:
			for child in get_children():
				if child is ShootingPoint:
					child.queue_free()
		notify_property_list_changed()
@export var danger_zone : bool = false:
	set(value):
		danger_zone = value
		if Engine.is_editor_hint() and not value:
			for child in get_children():
				if child is DangerZone:
					child.queue_free()
		notify_property_list_changed()
@export_group("Movement")
enum State {NONE, FOLLOW, WANDER, SEARCH}
@export var state: State = State.FOLLOW:
	set(value):
		if state != value:
			state = value
			if search:
				use_detection_area = true
			player_in_detection_area = false
			_update_detection_area()
			if Engine.is_editor_hint():
				update_gizmos()
				notify_property_list_changed()
@export_subgroup("Detection Area")
@export var use_detection_area : bool = false:
	set(value):
		if search and not value:
			use_detection_area = true
		else:
			use_detection_area = value
		if not use_detection_area:
			player_in_detection_area = false
		_update_detection_area()
		if Engine.is_editor_hint():
			update_gizmos()
			notify_property_list_changed()
@export var detection_radius : float = 5.0:
	set(value):
		detection_radius = max(value, 0.0)
		_update_detection_area()
		if Engine.is_editor_hint():
			update_gizmos()
		notify_property_list_changed()
@export var static_detection_area : bool = false
@export_subgroup("Stats")
@export var move_speed : float = 2.0
@export var lock_y_axis : bool = false
@export var apply_gravity : bool = false
@export_group("Sound")
@export var walk_footsteps : Array[AudioStream]
@export var shooting_sound : AudioStream
@export_group("Misc")
@export_subgroup("Nametag")
@export var show_nametag : bool = false:
	set(value):
		show_nametag = value
		if nametag and nametag.is_inside_tree():
			nametag.visible = value
			if value:
				update_nametag_position()
@export var nametag_size : float = 0.01:
	set(value):
		nametag_size = max(value, 0.001)  
		if nametag and nametag.is_inside_tree():
			nametag.pixel_size = nametag_size
@export var nametag_height_offset : float = -1.0:
	set(value):
		nametag_height_offset = value
		if nametag and nametag.is_inside_tree():
			update_nametag_position()

@onready var player : CharacterBody3D = get_node_or_null("/root/" + get_tree().current_scene.name + "/player")

var follow : bool:
	get:
		return state == State.FOLLOW
var wander : bool:
	get:
		return state == State.WANDER
var search : bool:
	get:
		return state == State.SEARCH

var shooting_timers : Dictionary = {}
var enemyBody : Node3D
var detection_area : Area3D
var player_in_detection_area : bool = false
var detection_area_inital_position : Vector3
var gravity : float = 9.8
var ground_raycast : RayCast3D
var navigation_agent : NavigationAgent3D
var wander_timer : float = 0.0
var wander_interval : float = 5.0
var last_known_player_pos : Vector3
var search_timer : float = 0.0 
var search_duration : float = 5.0 
var animation_player : AnimationPlayer
var walk_animation : String = ""
var fire_sound_players: Dictionary = {}
var nametag : Label3D
var floor_bounds : AABB
var rng : RandomNumberGenerator
var footstep_timer : float = 0.0
var footstep_interval : float = 0.5 
var footstep_player : AudioStreamPlayer3D

func _ready() -> void:
	if Engine.is_editor_hint():
		return 
	for child in get_children():
		if child is Node3D and not child is ShootingPoint:
			enemyBody = child
			break
	if walk_footsteps:
		footstep_player = AudioStreamPlayer3D.new()
		footstep_player.name = "FootstepSound"
		rng = RandomNumberGenerator.new()
		add_child(footstep_player) 
		footstep_player.owner = owner if owner else self
	if shooting:
		for child in get_children():
			if child is ShootingPoint:
				var timer = Timer.new()
				timer.wait_time = child.fire_rate
				timer.autostart = true
				timer.connect("timeout", Callable(self, "_fire_bullet").bind(child))
				add_child(timer)
				shooting_timers[child] = timer
				
				var audio_player = AudioStreamPlayer3D.new()
				audio_player.name = "FireSound_" + child.name
				audio_player.stream = shooting_sound
				audio_player.max_distance = 35.0
				child.add_child(audio_player)
				audio_player.owner = owner if owner else self
				fire_sound_players[child] = audio_player
	if apply_gravity:
		ground_raycast = RayCast3D.new()
		ground_raycast.name = "GroundRaycast"
		ground_raycast.target_position = Vector3(0, -0.2, 0) # Shortened for precise floor check
		ground_raycast.collision_mask = 1
		enemyBody.add_child(ground_raycast)
		ground_raycast.owner = owner if owner else self
		ground_raycast.global_position = enemyBody.global_position
		ground_raycast.enabled = true
		ground_raycast.force_raycast_update()
		if ground_raycast.is_colliding():
			var ground_point = ground_raycast.get_collision_point()
			enemyBody.global_position.y = ground_point.y + 0.1
			if debug:
				print("Spawn: Snapped to ground at ", ground_point)
		else:
			if debug:
				print("Spawn: No ground detected, y = ", enemyBody.global_position.y)
	if enemyBody: 
		navigation_agent = NavigationAgent3D.new()
		navigation_agent.name = "NavigationAgent"
		navigation_agent.path_desired_distance = 0.5
		navigation_agent.target_desired_distance = 1.0
		navigation_agent.avoidance_enabled = true
		navigation_agent.path_height_offset = 0.2
		enemyBody.add_child(navigation_agent)
		navigation_agent.owner = owner if owner else self
	_setup_detection_area()
	
	if wander or follow or search:
		if debug:
			print("Deferring navigation region creation")
		call_deferred("_create_navigation_region_deferred")
	
	animation_player = get_node_or_null("AnimationPlayer")
	if animation_player:
		for anim in animation_player.get_animation_list():
			var anim_lower = anim.to_lower()
			if "walk" in anim_lower or "run" in anim_lower:
				walk_animation = anim
				break
		if walk_animation == "" and debug:
			print("No 'walk' or 'run' animation found in AnimationPlayer")
	
	if show_nametag:
		var enemy_name = enemyBody.name if enemyBody else name
		nametag = Label3D.new()
		nametag.text = enemy_name
		nametag.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		nametag.pixel_size = nametag_size
		nametag.visible = show_nametag
		if enemyBody:
			enemyBody.add_child(nametag)
			nametag.owner = enemyBody.owner if enemyBody.owner else self
		else:
			add_child(nametag)
			nametag.owner = owner if owner else self
		update_nametag_position()
		set_process(true)
	
	if not player:
		print("Warning: Player node not found at /root/" + get_tree().current_scene.name + "/player")

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if enemyBody:
		var is_moving = false
		if apply_gravity and ground_raycast:
			var raycast_pos = enemyBody.global_position
			ground_raycast.global_position = raycast_pos
			ground_raycast.target_position = Vector3(0, -0.2, 0)
			ground_raycast.force_raycast_update()
			if ground_raycast.is_colliding():
				var ground_point = ground_raycast.get_collision_point()
				enemyBody.global_position.y = ground_point.y + 0.1
				if debug:
					print("Gravity: Snapped to ground at ", ground_point)
			else:
				enemyBody.global_position.y -= gravity * delta
				if debug:
					print("Gravity: Falling, y = ", enemyBody.global_position.y)
		if follow and player:
			var should_follow = not use_detection_area or player_in_detection_area
			if debug:
				print("Follow mode: should_follow = ", should_follow, " | player_in_detection_area = ", player_in_detection_area)
			if should_follow:
				var target_pos = player.global_position 
				if apply_gravity:
					target_pos = NavigationServer3D.map_get_closest_point(navigation_agent.get_navigation_map(), player.global_position)
				if target_pos != Vector3.ZERO:
					navigation_agent.set_target_position(target_pos)
					if debug:
						print("Follow target set to: ", target_pos, " | Player position: ", player.global_position)
					if not apply_gravity or not navigation_agent.is_navigation_finished():
						_move_to_target(delta)
						is_moving = true
					else:
						if debug:
							print("Navigation finished or no valid path to player")
				else:
					if debug:
						print("Invalid follow target: ", target_pos)
		elif wander:
			wander_timer -= delta
			if wander_timer <= 0 or navigation_agent.is_navigation_finished():
				_set_wander_target()
			if not navigation_agent.is_navigation_finished():
				_move_to_target(delta)
				is_moving = true
		elif search and player:
			if player_in_detection_area:
				var target_pos = player.global_position
				if apply_gravity:
					target_pos = NavigationServer3D.map_get_closest_point(navigation_agent.get_navigation_map(), player.global_position)
				if target_pos != Vector3.ZERO:
					navigation_agent.set_target_position(target_pos)
					last_known_player_pos = target_pos
					search_timer = search_duration
					if debug:
						print("Search target set to: ", target_pos)
					if not apply_gravity or not navigation_agent.is_navigation_finished():
						_move_to_target(delta)
						is_moving = true
			else:
				search_timer -= delta
				if search_timer > 0:
					if navigation_agent.get_target_position() != last_known_player_pos or navigation_agent.is_navigation_finished():
						navigation_agent.set_target_position(last_known_player_pos)
						if debug:
							print("Search continuing to last known position: ", last_known_player_pos)
					if not apply_gravity or not navigation_agent.is_navigation_finished():
						_move_to_target(delta)
						is_moving = true
				else:
					wander_timer -= delta
					if wander_timer <= 0 or navigation_agent.is_navigation_finished():
						_set_wander_target()
					if not navigation_agent.is_navigation_finished():
						_move_to_target(delta)
						is_moving = true
		if use_detection_area and static_detection_area and detection_area:
			detection_area.global_position = detection_area_inital_position
		
		if animation_player and walk_animation != "":
			if is_moving and not animation_player.is_playing():
				animation_player.play(walk_animation)
			elif not is_moving and animation_player.is_playing():
				animation_player.stop()
		
		if walk_footsteps and footstep_player:
			_play_footstep_sounds(delta)
	
	if nametag:
		nametag.visible = show_nametag
		if show_nametag:
			update_nametag_position()

func _fire_bullet(point : ShootingPoint) -> void:
	if not point or not point.bullet_scene:
		if debug:
			print("Point not found or bullet scene not found")
		return
	if point.Aim_at_player:
		if player:
			point.look_at(player.global_position, Vector3.UP)
	
	var bullet = point.bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_transform = point.global_transform
	bullet.linear_velocity = -point.global_transform.basis.z.normalized() * bullet.speed
	
	bullet.lifetime = point.bullet_lifetime
	bullet.damage = point.damage
	bullet.speed = point.bullet_speed
	
	var mesh = bullet.get_node("Mesh")
	if mesh and mesh is MeshInstance3D:
		var material = StandardMaterial3D.new()
		material.albedo_color = point.Bullets_color
		mesh.material_override = material
	
	if point in fire_sound_players:
		fire_sound_players[point].play()

func _move_to_target(delta: float) -> void:
	var target_pos = navigation_agent.get_target_position()
	if apply_gravity and target_pos.distance_to(enemyBody.global_position) < 0.1:
		if debug:
			print("Target too close, skipping: ", target_pos)
		return
	var current_pos = enemyBody.global_position
	var direction = (target_pos - current_pos).normalized()
	var new_position = current_pos + direction * delta * move_speed
	if apply_gravity:
		new_position.y = enemyBody.global_position.y
	enemyBody.global_position = new_position
	if lock_y_axis: 
		var look_dir = (target_pos - current_pos).normalized()
		look_dir.y = 0
		if look_dir.length() > 0:
			enemyBody.look_at(enemyBody.global_position + look_dir, Vector3.UP)
	else:
		enemyBody.look_at(target_pos, Vector3.UP)
	if debug:
		var path = navigation_agent.get_current_navigation_path()
		print("Moving to: ", target_pos, " | Current position: ", enemyBody.global_position, " | Nav finished: ", navigation_agent.is_navigation_finished())
		print("Current path points: ", path)
		if floor_bounds:
			var adjusted_bounds = AABB(floor_bounds.position - Vector3(0, 5.0, 0), floor_bounds.size + Vector3(0, 10.0, 0))
			print("Enemy pos in adjusted floor bounds: ", adjusted_bounds.has_point(enemyBody.global_position), " | Target pos in adjusted floor bounds: ", adjusted_bounds.has_point(target_pos))

func _set_wander_target() -> void:
	if not navigation_agent or not enemyBody:
		if debug:
			print("Navigation agent or enemyBody missing")
		return
	var nav_region = _find_nearest_navigation_region()
	if not nav_region:
		if debug:
			print("No navigation region found")
		return
	var nav_mesh = nav_region.navigation_mesh
	if not nav_mesh:
		if debug:
			print("No navigation mesh in region")
		return
	if debug and floor_bounds:
		print("Floor bounds for wander: ", floor_bounds, " | Enemy pos: ", enemyBody.global_position)
		print("Nav mesh vertices: ", nav_mesh.get_vertices())
	var max_attempts = 30
	var center = floor_bounds.get_center()
	var size = floor_bounds.size * 0.5 
	var adjusted_bounds = AABB(center - size * 0.5, size)
	for i in range(max_attempts):
		var random_offset = Vector3(
			randf_range(adjusted_bounds.position.x, adjusted_bounds.end.x),
			floor_bounds.position.y + 0.7 if apply_gravity else randf_range(-5.0, 5.0),
			randf_range(adjusted_bounds.position.z, adjusted_bounds.end.z)
		)
		var test_pos = random_offset
		var closest_pos = test_pos if not apply_gravity else NavigationServer3D.map_get_closest_point(navigation_agent.get_navigation_map(), test_pos)
		if closest_pos != Vector3.ZERO:
			if not apply_gravity:
				navigation_agent.set_target_position(closest_pos)
				wander_timer = wander_interval
				if debug:
					print("Wander target set to: ", closest_pos, " | Attempt: ", i)
				return
			else:
				var planar_distance = Vector2(closest_pos.x, closest_pos.z).distance_to(Vector2(test_pos.x, test_pos.z))
				var distance = closest_pos.distance_to(test_pos)
				if planar_distance < 0.5 and distance < 1.5:
					navigation_agent.set_target_position(closest_pos)
					wander_timer = wander_interval
					if debug:
						print("Wander target set to: ", closest_pos, " | Attempt: ", i, " | Distance: ", distance, " | Planar distance: ", planar_distance)
					return
				else:
					if debug:
						print("Wander attempt ", i, " failed: closest_pos = ", closest_pos, " | test_pos = ", test_pos, " | distance = ", distance, " | planar_distance = ", planar_distance)
		else:
			if debug:
				print("Wander attempt ", i, " failed: closest_pos = ", closest_pos, " | test_pos = ", test_pos)
	if debug:
		print("Wander target fallback to current position")
	navigation_agent.set_target_position(enemyBody.global_position)
	wander_timer = wander_interval

func _setup_detection_area() -> void:
	if detection_area:
		detection_area.queue_free()
		detection_area = null
	if not enemyBody or not use_detection_area:
		return
	detection_area = Area3D.new()
	detection_area.name = "DetectionArea"
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = detection_radius
	collision_shape.shape = sphere_shape
	detection_area.add_child(collision_shape)
	enemyBody.add_child(detection_area)
	detection_area.owner = owner if owner else self
	detection_area.global_position = global_position
	if static_detection_area:
		detection_area_inital_position = detection_area.global_position
	if not Engine.is_editor_hint():
		detection_area.body_entered.connect(_on_detection_area_body_entered)
		detection_area.body_exited.connect(_on_detection_area_body_exited)
		if debug:
			var debug_mesh = MeshInstance3D.new()
			debug_mesh.name = "DebugMesh"
			var sphere_mesh = SphereMesh.new()
			sphere_mesh.radius = detection_radius
			sphere_mesh.height = detection_radius * 2
			sphere_mesh.radial_segments = 32
			sphere_mesh.rings = 16
			var material = StandardMaterial3D.new()
			material.albedo_color = Color(0.0, 1.0, 0.0, 0.3)
			material.flags_transparent = true
			material.flags_unshaded = true
			debug_mesh.mesh = sphere_mesh
			debug_mesh.material_override = material
			detection_area.add_child(debug_mesh)
	if Engine.is_editor_hint():
		update_gizmos()

func _find_nearest_navigation_region() -> NavigationRegion3D:
	var regions = get_tree().get_nodes_in_group("navigation_regions")
	if debug:
		print("Found navigation regions: ", regions.size(), " regions")
		for region in regions:
			print("Region: ", region.name, " at ", region.global_position)
	var closest_region : NavigationRegion3D = null
	var min_distance : float = INF
	for region in regions:
		if region is NavigationRegion3D:
			var distance = enemyBody.global_position.distance_to(region.global_position)
			if debug:
				print("Region ", region.name, " distance: ", distance)
			if distance < min_distance:
				min_distance = distance
				closest_region = region
	if debug and closest_region:
		print("Selected closest region: ", closest_region.name)
	return closest_region

func _update_detection_area() -> void:
	if Engine.is_editor_hint():
		if not enemyBody:
			for child in get_children():
				if child is Node3D and not child is ShootingPoint:
					enemyBody = child
					break
		if use_detection_area:
			_setup_detection_area()
			if detection_area:
				var collision_shape = detection_area.get_node_or_null("CollisionShape3D")
				if collision_shape and collision_shape.shape is SphereShape3D:
					collision_shape.shape.radius = detection_radius
				if static_detection_area:
					detection_area.global_position = global_position
		else:
			if detection_area:
				detection_area.queue_free()
				detection_area = null
		update_gizmos()
	else:
		if use_detection_area:
			_setup_detection_area()
			if detection_area:
				var debug_mesh = detection_area.get_node_or_null("DebugMesh")
				if debug and not debug_mesh:
					var debug_mesh_new = MeshInstance3D.new()
					debug_mesh_new.name = "DebugMesh"
					var sphere_mesh = SphereMesh.new()
					sphere_mesh.radius = detection_radius
					sphere_mesh.height = detection_radius * 2
					sphere_mesh.radial_segments = 32
					sphere_mesh.rings = 16
					var material = StandardMaterial3D.new()
					material.albedo_color = Color(0.0, 1.0, 0.0, 0.5)
					material.flags_transparent = true
					material.flags_unshaded = true
					debug_mesh_new.mesh = sphere_mesh
					debug_mesh_new.material_override = material
					detection_area.add_child(debug_mesh_new)
				elif not debug and debug_mesh:
					debug_mesh.queue_free()
		else:
			if detection_area:
				detection_area.queue_free()
				detection_area = null

func _on_detection_area_body_entered(body: Node3D) -> void:
	if body == player:
		player_in_detection_area = true
		if debug:
			print("Player entered detection area")

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body == player:
		player_in_detection_area = false
		if debug:
			print("Player exited detection area")

func get_highest_point() -> Vector3:
	if not enemyBody:
		return global_position
	var base_pos = enemyBody.global_position
	var height_offset = 2.0
	if enemyBody is MeshInstance3D:
		var mesh = enemyBody.mesh
		if mesh:
			var aabb = mesh.get_aabb()
			height_offset = aabb.size.y * enemyBody.scale.y
	elif enemyBody.get_child_count() > 0:
		for child in enemyBody.get_children():
			if child is MeshInstance3D and child.mesh:
				var aabb = child.mesh.get_aabb()
				height_offset = max(height_offset, aabb.size.y * child.scale.y)
	return base_pos + Vector3(0, height_offset, 0)

func update_nametag_position():
	if not nametag or not enemyBody:
		return
	if nametag.get_parent() != enemyBody:
		if nametag.is_inside_tree():
			nametag.get_parent().remove_child(nametag)
		enemyBody.add_child(nametag)
		nametag.owner = enemyBody.owner if enemyBody.owner else self
	var highest_point = get_highest_point()
	nametag.global_position = highest_point + Vector3(0, nametag_height_offset, 0)

func is_enemy_descendant(node: Node) -> bool:
	var current = node
	while current != null:
		if current == self or current == enemyBody or current.is_in_group("enemy"):
			return true
		current = current.get_parent()
	return false

func create_navigation_region():
	var nav_region = NavigationRegion3D.new()
	nav_region.name = "NavigationRegion3D"
	nav_region.add_to_group("navigation_regions")
	
	var nav_mesh = NavigationMesh.new()
	nav_mesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_MESH_INSTANCES | NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	nav_mesh.cell_size = 0.05
	nav_mesh.cell_height = 0.05
	nav_mesh.agent_height = 1.0
	nav_mesh.agent_radius = 0.5
	nav_mesh.agent_max_slope = 45.0
	nav_region.navigation_mesh = nav_mesh
	
	var floor_meshes: Array[GeometryInstance3D] = []
	var obstacle_meshes: Array[GeometryInstance3D] = []
	
	var all_nodes = get_all_nodes(get_tree().root)
	for node in all_nodes:
		if node.name.begins_with("!"):
			if debug:
				print("Skipping node with '!': ", node.name)
			continue
		if is_enemy_descendant(node):
			if debug:
				print("Skipping enemy-related node: ", node.name)
			continue
			
		if "floor" in node.name.to_lower():
			if node is MeshInstance3D or node is CSGBox3D:
				floor_meshes.append(node)
				if debug:
					print("Found direct floor node: ", node.name)
			else:
				var children = get_geometry_children(node)
				for child in children:
					if child is CSGBox3D:
						var parent = child.get_parent()
						if parent is CSGCombiner3D and child.operation == CSGShape3D.OPERATION_SUBTRACTION:
							if debug:
								print("Found valid subtract CSGBox3D child: ", child.name)
							floor_meshes.append(child)
						else:
							if debug:
								print("Skipping CSGBox3D (not subtract or not in combiner): ", child.name)
					else:
						floor_meshes.append(child)
						if debug:
							print("Found floor child geometry: ", child.name)
		
		elif (node is MeshInstance3D or node is CSGBox3D) and not has_floor_ancestor(node):
			obstacle_meshes.append(node)
			if debug:
				print("Found obstacle: ", node.name)
	
	if debug:
		print("Total nodes processed: ", all_nodes.size())
		print("Floors found: ", floor_meshes.size())
		print("Obstacles found: ", obstacle_meshes.size())
	
	if floor_meshes.size() > 0:
		floor_bounds = AABB()
		for floor in floor_meshes:
			if floor is MeshInstance3D and floor.mesh:
				var aabb = floor.mesh.get_aabb()
				var scale = floor.scale
				var scaled_aabb = AABB(aabb.position * scale, aabb.size * scale)
				var transformed_aabb = scaled_aabb.translated(floor.global_position)
				floor_bounds = floor_bounds.merge(transformed_aabb) if floor_bounds else transformed_aabb
			elif floor is CSGBox3D:
				var aabb = AABB(floor.global_position - floor.size * 0.5, floor.size)
				floor_bounds = floor_bounds.merge(aabb) if floor_bounds else aabb
		if debug:
			print("Computed floor bounds: ", floor_bounds)
	
	get_tree().current_scene.add_child(nav_region)
	nav_region.owner = get_tree().current_scene
	if debug:
		print("Navigation region added to scene at: ", nav_region.global_position)
		print("Navigation region in tree: ", nav_region.is_inside_tree())
		print("Navigation region groups: ", nav_region.get_groups())
		print("Current scene: ", get_tree().current_scene.name)
		print("Nodes in navigation_regions group: ", get_tree().get_nodes_in_group("navigation_regions"))
	
	if floor_meshes.is_empty():
		if debug:
			print("Warning: No floor geometry found!")
	else:
		var source_geometry = NavigationMeshSourceGeometryData3D.new()
		for floor in floor_meshes:
			if floor is MeshInstance3D and floor.mesh:
				source_geometry.add_mesh(floor.mesh, floor.global_transform)
				if debug:
					print("Added floor mesh: ", floor.name)
			elif floor is CSGBox3D:
				var box_mesh = BoxMesh.new()
				box_mesh.size = floor.size
				source_geometry.add_mesh(box_mesh, floor.global_transform)
				if debug:
					print("Added CSGBox3D as mesh: ", floor.name)
		
		NavigationServer3D.bake_from_source_geometry_data(nav_mesh, source_geometry, func():
			if debug:
				print("Navigation mesh baking completed")
				if nav_mesh.get_polygon_count() == 0:
					print("Warning: Navigation mesh is empty! Vertices: ", nav_mesh.get_vertices())
				else:
					print("Navigation mesh polygons: ", nav_mesh.get_polygon_count())
					print("Navigation mesh vertices: ", nav_mesh.get_vertices()))
	
	for obstacle in obstacle_meshes:
		var obstacle_node = NavigationObstacle3D.new()
		obstacle_node.name = "Obstacle_" + obstacle.name
		nav_region.add_child(obstacle_node)
		obstacle_node.global_transform = obstacle.global_transform
		obstacle_node.affect_navigation_mesh = true
		if obstacle is MeshInstance3D and obstacle not in floor_meshes and obstacle.mesh:
			var aabb = obstacle.mesh.get_aabb()
			var scale = obstacle.scale
			obstacle_node.height = aabb.size.y * scale.y
			obstacle_node.radius = max(aabb.size.x * scale.x, aabb.size.z * scale.z) * 0.5
			if debug:
				print("Obstacle ", obstacle.name, " position: ", obstacle.global_position, " | height: ", obstacle_node.height, " | radius: ", obstacle_node.radius)
		elif obstacle is CSGBox3D:
			var size = obstacle.size
			var scale = obstacle.scale
			obstacle_node.height = size.y * scale.y
			obstacle_node.radius = max(size.x * scale.x, size.z * scale.z) * 0.5
			if debug:
				print("Obstacle ", obstacle.name, " position: ", obstacle.global_position, " | height: ", obstacle_node.height, " | radius: ", obstacle_node.radius)
	
	if debug:
		print("Navigation region created with ", floor_meshes.size(), " floors and ", obstacle_meshes.size(), " obstacles")
	
	call_deferred("_set_navigation_map", nav_region)

func _set_navigation_map(nav_region: NavigationRegion3D) -> void:
	if debug:
		print("Attempting to set navigation map for region: ", nav_region.name)
	if nav_region.is_inside_tree():
		var world_3d = nav_region.get_world_3d()
		if world_3d and world_3d.navigation_map:
			navigation_agent.set_navigation_map(world_3d.navigation_map)
			if debug:
				print("Navigation agent linked to map: ", world_3d.navigation_map)
				print("Nodes in navigation_regions group after map set: ", get_tree().get_nodes_in_group("navigation_regions"))
		else:
			if debug:
				print("Failed to get World3D or navigation map for region: ", nav_region.name)
	else:
		if debug:
			print("Navigation region not in tree, cannot set navigation map")

func get_all_nodes(node: Node, nodes: Array[Node] = []) -> Array[Node]:
	nodes.append(node)
	for child in node.get_children():
		get_all_nodes(child, nodes)
	return nodes

func get_geometry_children(node: Node) -> Array[GeometryInstance3D]:
	var geometries: Array[GeometryInstance3D] = []
	for child in node.get_children():
		if child is MeshInstance3D or child is CSGBox3D:
			geometries.append(child)
	return geometries

func has_floor_ancestor(node: Node) -> bool:
	var current = node
	while current != null:
		if "floor" in node.name.to_lower():
			return true
		current = current.get_parent()
	return false

func _play_footstep_sounds(delta: float) -> void:
	if is_on_floor() and not footstep_player.playing:
		footstep_timer += delta 
		if footstep_timer >= footstep_interval:
			footstep_player.stream = walk_footsteps[rng.randi_range(0, walk_footsteps.size() - 1)]
			footstep_player.play() 
			footstep_timer = 0.0  

func is_on_floor() -> bool:
	if not apply_gravity or not ground_raycast or not enemyBody:
		return false
	ground_raycast.global_position = enemyBody.global_position + Vector3(0, 0.05, 0) # Slight offset to avoid clipping
	ground_raycast.target_position = Vector3(0, -0.2, 0) # Short distance to detect floor
	ground_raycast.force_raycast_update()
	return ground_raycast.is_colliding()

func delete_all(node : String, value : bool) -> void:
	if Engine.is_editor_hint() and not value:
		for child in get_children():
			if child.is_class(node):
				child.queue_free()
		notify_property_list_changed()
