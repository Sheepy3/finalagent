extends Node3D
var debugshader:StandardMaterial3D = load("res://Assets/DebugMesh.tres")
func vision_poll(agent:Node3D) -> Array: 
	var nodes:Array = get_tree().get_nodes_in_group("Agent")
	var in_sight:Array
	for node:Node3D in nodes:
		if node != agent: #dont put self! 
			#print(node.name)
			in_sight.push_front(node.position)
	return in_sight

func is_enemy_in_fov(seeker: Node3D, enemy_position: Vector3, fov: int) -> bool:
	var player_position:Vector3 = seeker.position 
	var player_direction:Vector3 = -seeker.global_transform.basis.z   #convert euler rotation to  (Vector3.FORWARD *Basis.from_euler(seeker.rotation))
	var to_enemy: Vector3 = enemy_position - player_position    
	
	var player_direction_normalized: Vector3 = player_direction.normalized()
	var to_enemy_normalized: Vector3 = to_enemy.normalized()

	var dot_product: float = player_direction_normalized.dot(to_enemy_normalized)
	var angle_rad: float = acos(dot_product)
	var angle_deg: float = rad_to_deg(angle_rad)

	var cone_mesh:CylinderMesh = CylinderMesh.new()
	cone_mesh.top_radius = 0
	cone_mesh.height = 10
	cone_mesh.bottom_radius = cone_mesh.height*tan((deg_to_rad(fov))/2)
	cone_mesh.material = debugshader
	
	var fov_mesh:MeshInstance3D = MeshInstance3D.new()
	seeker.add_child(fov_mesh)
	fov_mesh.position -=(Vector3(0,0,cone_mesh.height/2))
	fov_mesh.rotate_x(PI/2)
	fov_mesh.mesh = cone_mesh

	await get_tree().create_timer(0.1).timeout # Wait for a short time to allow visualization. 
	#TODO:breakout visualization into separate function
	fov_mesh.queue_free()
	return angle_deg <= (fov / 2.0)
	
func pass_agent(agent_node:Node3D) -> void:
	var debugger:Panel = get_tree().root.find_child("AgentDebugger", true, false)
	debugger.find_child("UUID").text = agent_node.name
	debugger.agent_to_debug = agent_node
	print("success")
