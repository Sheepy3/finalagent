extends Camera3D
class_name FlyCamera
## Simple Fly Camera for Godot Engine 3.x / 4.x.
## This Fly camera can be moved using the mouse and keyboard "WASD".
## You can toggle this camera activation by pressing the TAB key.
## The idea is to put this camera as autoload.
## It's possible to customize it by changing: The mouse `sensibility` and camera `speed`.
## 
## If you want to contribute, please leave a comment, I'll update the code.
## 
## License: MIT. 
## 
## ~~~~~~~~~~~~~~~~
## Make this discoverable by people:
## How to create a fly camera in Godot?
## Godot fly camera.
## Fly camera tutorial.
## Fly camera utility.
## ~~~~~~~~~~~~~~~~
## 

# ------------------------------------------------------------------------ Const

const sensitivity = 0.001

# ----------------------------------------------------------------------- Global
var active := true
var motion: Vector3
var view_motion: Vector2
var gimbal_base: Transform3D
var gimbal_pitch: Transform3D
var gimbal_yaw: Transform3D
var speed:float = 0.1

# ----------------------------------------------------------------------- Public
func is_active() -> bool:
	""" Return true when the fly camera is active. You can toggle the fly
	camera using the TAB keyboard. """
	return active


# ----------------------------------------------------------------- Notification
func _ready() -> void:
	gimbal_base.origin = global_transform.origin
	# Unparent
	set_as_top_level(true)
	update_activation()


func _input(event:InputEvent) ->void:
	if event is InputEventMouseMotion and active:
		view_motion += event.relative
		get_viewport().set_input_as_handled()

	elif event is InputEventKey:
		if event.keycode == KEY_TAB:
			if event.pressed:
				# Each click toggle.
				active = active == false
				update_activation()
				return
		if active == false:
			return

		var value: float = 0
		if event.pressed:
			value = 1

		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if event.keycode == KEY_W:
			motion.z = value * -1.0
		elif event.keycode == KEY_S:
			motion.z = value
		elif event.keycode == KEY_A:
			motion.x = value * -1.0
		elif event.keycode == KEY_D:
			motion.x = value
		else:
			pass
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				#print($RayCast3D.get_collider())
				if $RayCast3D.get_collider() and $RayCast3D.get_collider().is_in_group("Agent"):
					Overseer.pass_agent($RayCast3D.get_collider())
				else:
					print("Not an agent!")

		get_viewport().set_input_as_handled()


func _process(delta:float) -> void:
	gimbal_base *= Transform3D(Basis(), global_transform.basis * (motion * speed))

	gimbal_yaw = gimbal_yaw.rotated(Vector3(0,1,0), view_motion.x * sensitivity * -1.0)
	gimbal_pitch = gimbal_pitch.rotated(Vector3(1,0,0), view_motion.y * sensitivity * -1.0)
	view_motion = Vector2()

	global_transform = gimbal_base * (gimbal_yaw * gimbal_pitch)
	if Input.is_key_pressed(KEY_SHIFT):
		speed = 0.3
	else:
		speed = 0.1

# ---------------------------------------------------------------------- Private
func update_activation() -> void:
	#set_process(active)
	#current = active
	if active == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
