extends Enemy

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func apply_speed():
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent_2d.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * SPEED

func jump_logic():
	pass

func apply_gravity(delta):
	pass
