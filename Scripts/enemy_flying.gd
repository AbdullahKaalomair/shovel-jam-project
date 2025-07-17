extends Enemy

@onready var cieling_detector: RayCast2D = $CielingDetector

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func apply_speed():
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent_2d.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * SPEED
	
	if(cieling_detector.is_colliding() or abs(velocity.x) < 3) and velocity.x != 0: 
		var dir = velocity.x
		print()
		velocity.x += 10 * (-1 * ((velocity.x)/(velocity.x)))

func jump_logic():
	pass

func apply_gravity(delta):
	pass
