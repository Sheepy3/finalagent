extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity:float = ProjectSettings.get_setting("physics/3d/default_gravity")
#var ahf:Script = load()
var ahf := preload("res://FinalAgent/Helpers/ahf.gd").new(self)
const uuid_util = preload('res://addons/uuid/uuid.gd')
@export var current_goal:String = ""
@export var current_action:String = "Idle"
@export var Agentdata:AgentData
@onready var nav:NavigationAgent3D = $NavigationAgent3D
@onready var origin:Marker3D = $Origin

var vision_target_global:Vector3
#var target_rotation:int 
var speed:int = 2
var accel:int = 10
var state_switch:bool
func _ready() -> void:
	origin.top_level = true

func _physics_process(delta:float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
### STATE INTERRUPT ###
	
	
### STATE HANDLING ###
	match current_action.to_lower():
		"walking":
			if state_switch:
				state_switch = false
				var goalplace:Vector3 = await ahf.place_goal(ahf.get_random_position_around_node(self,4,5)) 
				if goalplace != Vector3(0,0,0):
					$GiveUpTimer.start()
					nav.target_position = goalplace
				else:
					print("Failed to place goal.")
					state_switch = true
			var direction := Vector3()
			direction = nav.get_next_path_position() - global_position # and so does this
			direction = direction.normalized()
			velocity = velocity.lerp(direction * speed, accel * delta)
		"idle":
			velocity.x = lerp(velocity.x, 0.0, 0.1)
			velocity.z = lerp(velocity.z, 0.0, 0.1)
		"looking_for_enemies":
			for nodes:Vector3 in Overseer.vision_poll(self):
				var is_in_fov: = await Overseer.is_enemy_in_fov(self, nodes, 50)
				if is_in_fov:
					print(is_in_fov)
					pass
				#player_position: Vector3, player_direction: Vector3, enemy_position: Vector3, fov: int) -> bool:
			pass
	move_and_slide()
	$current_action.set_text(current_action)

func _switch_state(newstate:String) -> void:
	current_action = newstate
	state_switch = true
	pass

func _on_timer_timeout() -> void:
	if current_action == "Idle":
		_switch_state("walking")

func _on_navigation_agent_3d_target_reached() -> void:
	_switch_state("Idle")
	velocity = Vector3(0,0,0) 
	
func _on_give_up_timer_timeout() -> void:
	print("chat lets just give up")
	_switch_state("Idle")
