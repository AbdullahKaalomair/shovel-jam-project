extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -1000.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
const BULLET = preload("res://Scenes/bullet.tscn")

func _process(delta: float) -> void:
	SkillLoop()

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true
	
	#manage animations
	if is_on_floor():
		if direction == 0:
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("jump")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()

func SkillLoop():
	if Input.is_action_just_pressed("shoot"):
		get_node("TurnAxis").rotation = get_angle_to(get_global_mouse_position())
		var bullet_instance = BULLET.instantiate()
		bullet_instance.position = get_node("TurnAxis/ShootPoint").get_global_position()
		bullet_instance.rotation = get_angle_to(get_global_mouse_position())
		get_parent().add_child(bullet_instance)
