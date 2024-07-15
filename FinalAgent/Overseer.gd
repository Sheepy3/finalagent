extends Node3D

func vision_poll(agent:Node3D) -> Array: 
	var nodes:Array = get_tree().get_nodes_in_group("Agent")
	var in_sight:Array
	for node:Node3D in nodes:
		if node != agent:
			#print(node.name)
			in_sight.push_front(node.position)
	return in_sight
	#pass

func is_enemy_in_fov(seeker: Node3D, enemy_position: Vector3, fov: int) -> bool:
	var player_position:Vector3 = seeker.position 
	var player_direction:Vector3 = seeker.rotation
	#var debug_node:Node3D = Node3D.new()
	#add_child(debug_node)
	var fov_mesh:MeshInstance3D = MeshInstance3D.new()
	seeker.add_child(fov_mesh)
	#fov_mesh.rotate_x(90)
	var cone_mesh:CylinderMesh = CylinderMesh.new()
	cone_mesh.top_radius = 0
	cone_mesh.height = 10
	cone_mesh.bottom_radius = cone_mesh.height*tan((deg_to_rad(fov))/2)
	fov_mesh.position +=(Vector3(0,0,cone_mesh.height/2))
	fov_mesh.rotate_x(-PI/2)
	var material: = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(1, 1, 1, 0.05)  # 50% transparent white
	cone_mesh.material = material
	fov_mesh.mesh = cone_mesh
	#fov_mesh.position = player_position	

	
	
	var to_enemy: Vector3 = enemy_position - player_position    
	# Normalize both vectors
	var player_direction_normalized: Vector3 = player_direction.normalized()
	var to_enemy_normalized: Vector3 = to_enemy.normalized()
	# Calculate the dot product
	var dot_product: float = player_direction_normalized.dot(to_enemy_normalized)
	# Calculate the angle in radians
	var angle_rad: float = acos(dot_product)
	# Convert angle to degrees
	var angle_deg: float = rad_to_deg(angle_rad)
	# Check if the angle is within half of the FOV
	await get_tree().create_timer(0.1).timeout
	fov_mesh.queue_free()

	return angle_deg <= (fov / 2.0)
		# Wait for a short time to allow visualization
