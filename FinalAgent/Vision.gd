extends ShapeCast3D
#@export var rotation_speed: float = 1.0  # Degrees per second
@export var max_angle: float = 40.0  # Maximum rotation angle in degrees
var phys_multiplier:int = 1
var direction: int = 1  # 1 for clockwise, -1 for counterclockwise

func _physics_process(delta:float) -> void:
	if get_parent().name == "Agent":
		queue_free()
	for i in range(phys_multiplier):
		rotate_y(deg_to_rad(0.5*direction))
		if abs(rotation_degrees.y) >= max_angle:
			direction *= -1
			rotation_degrees.y = max_angle * sign(rotation_degrees.y)
	var collision_count:int = get_collision_count() 
	for o in range(collision_count):
		var collider:CollisionObject3D = get_collider(o)
		if collider:
			print(collider.name)
			#var parent:Node3D = collider.get_parent()
			#if parent:
			#	print("Collider's parent name: ", parent.name)
			#else:
			#	print("Collider has no parent")
		else:
			print("No collider found for collision index ", o)
