extends CharacterBody2D
class_name Enemy

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var target: Tower 
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var wall_detection_right: RayCast2D = $WallDetectionRight
@onready var wall_detection_left: RayCast2D = $WallDetectionLeft
@onready var hit_timer: Timer = $HitTimer
@onready var death_audio_stream_player_2d: AudioStreamPlayer2D = $DeathAudioStreamPlayer2D
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D




var health = 3
var damage = 1
var jumpThreshold = 10 #This decides how slow the enemy has to be to decide to jump
var tripleJump = 3
var inTower = false

const SPEED = 110.0
const JUMP_VELOCITY = -350.0

signal givePoint(point)
signal death()

# Called when the node enters the scene tree for the first time.
func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent_2d.path_desired_distance = 10.0
	navigation_agent_2d.target_desired_distance = 0.01

	# Make sure to not await during _ready.
	actor_setup.call_deferred()
	
	# Make sure the shader is unique for each enemy.
	animated_sprite.material = animated_sprite.material.duplicate()

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(target.position)

func set_movement_target(movement_target: Vector2):
	navigation_agent_2d.target_position = movement_target

func _physics_process(delta: float) -> void:
	# direction calculation
	if navigation_agent_2d.is_navigation_finished():
		return
	
	apply_speed()
	
	animation_handle()
	
	jump_logic()
	
	apply_gravity(delta)
		
	move_and_slide()

func apply_speed():
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent_2d.get_next_path_position()

	velocity.x = current_agent_position.direction_to(next_path_position).x * SPEED

func jump_logic():
	#Enemy Jump Logic
	if (wall_detection_right.is_colliding() or wall_detection_left.is_colliding()) and tripleJump > 0:
		velocity.y = JUMP_VELOCITY
		tripleJump -= 1
	if velocity.x < jumpThreshold and velocity.x > jumpThreshold * -1 and tripleJump > 0:
		velocity.y = JUMP_VELOCITY
		tripleJump -= 1

func apply_gravity(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	else:
		tripleJump = 3
	
func take_damage(damage: int):
	emit_signal("givePoint", 1)
	health -= 1
	activate_hit_shader_effect()
	if health <= 0:
		emit_signal("givePoint", 5)
		area_2d.set_deferred("monitoring", false)
		collision_shape_2d.set_deferred("disabled", true)
		self.hide()
		death_audio_stream_player_2d.play()
		await death_audio_stream_player_2d.finished
		emit_signal("death")
		queue_free()

func animation_handle():
	var new_anim = ""

	if abs(velocity.x) < 1:
		new_anim = "idle"
	else:
		new_anim = "walk"
	if animated_sprite.animation != new_anim:
		animated_sprite.play(new_anim)
		
func inTowerSwitch():
	if inTower:
		inTower = false
	else:
		inTower = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.get_hit(global_position)


func activate_hit_shader_effect() -> void:
	animated_sprite.material.set_shader_parameter("active", true)
	hit_timer.start()

#func _on_jump_timer_timeout() -> void:
	#pass # Replace with function body.


func _on_hit_timer_timeout() -> void:
	animated_sprite.material.set_shader_parameter("active", false)
