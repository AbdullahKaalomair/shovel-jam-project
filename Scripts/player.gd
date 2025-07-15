extends CharacterBody2D
class_name Player

const SPEED = 130.0
const JUMP_VELOCITY = -400.0
@export var knockback_force := 400.0
var knockback_velocity := Vector2.ZERO
const KNOCKBACK_DECAY := 2200.0  # tweak to make knockback fade out
@export var hitstun_duration := 1.0  # seconds

var is_invulnerable := false
var ammo = 5

@onready var tower_interact_container: PanelContainer = $TowerInteractContainer
@onready var invulnerability_timer: Timer = $InvulnerabilityTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
const BULLET = preload("res://Scenes/bullet.tscn")

func _process(delta: float) -> void:
	Shoot()

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
	
	# Apply player input movement
	var move_input_x = 0.0
	if direction:
		move_input_x = direction * SPEED
	else:
		move_input_x = move_toward(velocity.x, 0, SPEED)

	# Apply knockback and decay it
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * delta)

	# Combine movement and knockback
	velocity.x = move_input_x + knockback_velocity.x
		
	move_and_slide()

func Shoot():
	if Input.is_action_just_pressed("shoot"):
		if ammo > 0:
			ammo -= 1
			get_node("TurnAxis").rotation = get_angle_to(get_global_mouse_position())
			var bullet_instance = BULLET.instantiate()
			bullet_instance.position = get_node("TurnAxis/ShootPoint").get_global_position()
			bullet_instance.rotation = get_angle_to(get_global_mouse_position())
			get_parent().add_child(bullet_instance)

func get_hit(from_position: Vector2) -> void:
	if is_invulnerable:
		return
		
	ammo = max(ammo - 2, 0)
	
	#Knockback
	var direction = (global_position - from_position).normalized()
	knockback_velocity = direction * knockback_force
	velocity.y = knockback_velocity.y
	
	is_invulnerable = true
	modulate = Color(1, 0.5, 0.5)  # Flash red or tint
	invulnerability_timer.start()


func _on_invulnerability_timer_timeout() -> void:
	is_invulnerable = false
	modulate = Color(1, 1, 1)  # Reset color

func enter_tower():
	tower_interact_container.visible = true

func exit_tower():
	tower_interact_container.visible = false
