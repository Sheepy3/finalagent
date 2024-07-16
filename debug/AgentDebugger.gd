extends Panel
@export var agent_to_debug:Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta:float) -> void:
	if agent_to_debug:
		$VBoxContainer/State.set_text(agent_to_debug.current_action) 
		pass
