extends CharacterBody2D
class_name Enemy

@export var target: Node2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var wall_detection: RayCast2D = $WallDetection

var health = 3
var damage = 1

const SPEED = 110.0
const JUMP_VELOCITY = -300.0

signal givePoint(point)

# Called when the node enters the scene tree for the first time.
func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent_2d.path_desired_distance = 4.0
	navigation_agent_2d.target_desired_distance = 4.0

	# Make sure to not await during _ready.
	actor_setup.call_deferred()

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(target.position)

func set_movement_target(movement_target: Vector2):
	navigation_agent_2d.target_position = movement_target


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if wall_detection.is_colliding():
		velocity.y = JUMP_VELOCITY

func _physics_process(delta: float) -> void:
	

		
	# direction calculation
	if navigation_agent_2d.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent_2d.get_next_path_position()

	velocity.x = current_agent_position.direction_to(next_path_position).x * SPEED 
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
		
	move_and_slide()


func take_damage():
	emit_signal("givePoint", 1)
	health -= 1
	print(health)
	if health <= 0:
		emit_signal("givePoint", 10)
		queue_free()


#func _on_area_2d_body_entered(body: Node2D) -> void:
	#if body is Tower:
		#body.enemy_attacking("enemy", 1)
