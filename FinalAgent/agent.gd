extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity:float = ProjectSettings.get_setting("physics/3d/default_gravity")
#var ahf:Script = load()
var ahf := preload("res://FinalAgent/Helpers/ahf.gd").new(self)
@export var current_goal:String = ""
@export var current_action:String = "Idle"
@export var Agentdata:AgentData
@onready var nav:NavigationAgent3D = $NavigationAgent3D

@onready var origin:Marker3D = $Origin
@onready var vision:RayCast3D = $RayCast3D
var vision_target_global:Vector3
var target_rotation:int 
var speed:int = 2
var accel:int = 10

func _ready() -> void:
	origin.top_level = true

func _physics_process(delta:float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	match current_action.to_lower():
		"walking":
			var direction := Vector3()
			 # this one needs the @onready vars we defined earlier
			direction = nav.get_next_path_position() - global_position # and so does this
			direction = direction.normalized()
			velocity = velocity.lerp(direction * speed, accel * delta)
		"idle":
			velocity.x = lerp(velocity.x, 0.0, 0.1)
			velocity.z = lerp(velocity.z, 0.0, 0.1)
		"turn":
			rotation.y = lerp_angle(rotation.y,target_rotation,1)
			if rotation.y == target_rotation:
				current_action == "Idle"
	move_and_slide()
	$current_action.set_text(current_action)


func _on_timer_timeout() -> void:
	if current_action == "Idle":
		do_a_walk()

func do_a_walk() -> void:
	vision_target_global = vision.global_position + vision.global_transform.basis * vision.target_position
	var goalplace:Vector3 = await ahf.place_goal(ahf.get_random_position_around_node(self,4,5)) 
	if goalplace != Vector3(0,0,0):
		print("yay")
		current_action = "walking"
		$GiveUpTimer.start()
		var pin_drop := find_child("PinDrop*", false, false)
		nav.target_position = goalplace
	else:
		print("Failed to place goal.")


func _on_navigation_agent_3d_target_reached() -> void:
	reset_target()
	current_action = "Idle"
	velocity = Vector3(0,0,0) 
	$GiveUpTimer.stop()
	#print("we did it bros")

func reset_target() -> void:
	find_child("PinDrop*", false, false).queue_free()

func _on_give_up_timer_timeout() -> void:
	print("chat lets just give up")
	reset_target()
	current_action = "Idle"
