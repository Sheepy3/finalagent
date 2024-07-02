extends RefCounted 

var parent_node: Node = null

func _init(parent: Node) -> void:
	parent_node = parent

func place_goal(input_position: Vector3) -> Vector3:
	#if parent_node.get_node("PinDrop")
	var goal := load("res://FinalAgent/Helpers/PathFindingGoal.tscn")
	var target:Node = goal.instantiate()
	parent_node.add_child(target)
	target.name="PinDrop"
	target.top_level = true
	if target:
		print("target placed")
	print("beginning to place goal")
	var navigation_region:NavigationRegion3D = parent_node.get_tree().get_current_scene().get_node("NavigationRegion3D")
	
	# 0. Teleport the goal above the inputted position
	var teleport_height:int = 10  # Adjust this value as needed
	target.global_position = input_position + Vector3.UP * teleport_height
	var raycast:RayCast3D = target.find_child("RayCast3D")
	
	# 1. Move the goal downwards until the raycast intersects the ground
	var max_iterations:int = 50  # Prevent infinite loop
	var iteration:int = 0
	
	while not raycast.is_colliding() and iteration < max_iterations:
		raycast.force_raycast_update()
		target.global_position -= Vector3.UP
		iteration += 1
		await parent_node.get_tree().process_frame  # This makes the function awaitable
	
	if iteration == max_iterations:
		print("Failed to find ground. Max iterations reached.")
		target.queue_free()  # Clean up the instantiated node
		return Vector3(0,0,0)
	
	# Adjust goal position to the exact intersection point
	target.global_position = raycast.get_collision_point()
	target.global_position += Vector3(0,1,0)
	print("hit ground")
	
	# 2. Detect if the goal is outside of the navmesh
	var navigation_map := navigation_region.get_world_3d().get_navigation_map()
	var closest_point := NavigationServer3D.map_get_closest_point(navigation_map, target.global_position)
	var distance_to_navmesh:float = target.global_position.distance_to(closest_point)
	
	if distance_to_navmesh > 2.1:  # Adjust this threshold as needed
		print("out of bounds :(")
		print(distance_to_navmesh)
		target.queue_free()  # Clean up the instantiated node
		return Vector3(0,0,0)
	
	# If we've reached this point, the goal is successfully placed
	print("Goal placed successfully")
	var result:Vector3 = target.global_position 
	target.queue_free()
	return result

func get_random_position_around_node(node: Node, min_distance:float, max_distance: float) -> Vector3:
	# Get the current global position of the node
	var current_position:Vector3 = node.global_position
	# Generate a random direction
	var random_direction:= Vector3(
		randf_range(-1, 1),
		node.global_position.y,
		randf_range(-1, 1)
	).normalized()
	
	# Generate a random distance within the specified range
	var random_distance := randf_range(min_distance, max_distance)
	# Calculate the offset
	var offset := random_direction * random_distance
	# Return the new position
	return current_position + offset
