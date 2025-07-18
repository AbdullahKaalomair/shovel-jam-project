extends CharacterBody2D
class_name Player

const SPEED = 130.0
const JUMP_VELOCITY = -350.0
@export var knockback_force := 400.0
var knockback_velocity := Vector2.ZERO
const KNOCKBACK_DECAY := 2200.0  # tweak to make knockback fade out
@export var hitstun_duration := 1.0  # seconds

var air_jump = false
var just_wall_jumped = false
var was_wall_normal = Vector2.ZERO

var is_invulnerable := false
var ammo = 10
var can_shoot = true
var gumballs = 0

@onready var tower_interact_container: PanelContainer = $TowerInteractContainer
@onready var invulnerability_timer: Timer = $InvulnerabilityTimer
@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer
@onready var wall_jump_timer: Timer = $WallJumpTimer
@onready var red_arrow: Sprite2D = $TurnAxises/TurnAxisTower/TowerPointer/RedArrow

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var gumball: Sprite2D = $Gumballs/Gumball
@onready var gumball_2: Sprite2D = $Gumballs/Gumball2
@onready var gumball_3: Sprite2D = $Gumballs/Gumball3
@onready var gumball_machine: Tower = %GumballMachine

#List of sounds
const NO_BULLET = preload("res://Assets/Sounds/Player/No_Bullet.wav")
const SHOOT_11 = preload("res://Assets/Sounds/Player/Shoot11.wav")

const BULLET = preload("res://Scenes/bullet.tscn")

func _process(delta: float) -> void:
	get_node("TurnAxises/TurnAxis").rotation = get_angle_to(get_global_mouse_position())
	if gumball_machine:
		get_node("TurnAxises/TurnAxisTower").rotation = get_angle_to(gumball_machine.position)
	Shoot()

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	handle_wall_jump()
	handle_jump()

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
		if velocity.y < 0:
			animated_sprite_2d.play("jump_up")
		else:
			animated_sprite_2d.play("jump_down")
	
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
		
	var was_on_floor = is_on_floor()
	var was_on_wall = is_on_wall_only()
	if was_on_wall:
		was_wall_normal = get_wall_normal()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	#if Input.is_action_just_pressed("ui_accept"):
		#movement_data = load("res://FasterMovementDara.tres")
	just_wall_jumped = false
	var just_left_wall = was_on_wall and not is_on_wall()
	if just_left_wall:
		wall_jump_timer.start()

func Shoot():
	if Input.is_action_just_pressed("shoot") and can_shoot:
		get_node("TurnAxises/TurnAxis").rotation = get_angle_to(get_global_mouse_position())

		if ammo > 0:
			# Shooting logic
			ammo -= 1

			var bullet_instance = BULLET.instantiate()
			bullet_instance.position = get_node("TurnAxises/TurnAxis/ShootPoint").get_global_position()
			bullet_instance.rotation = get_angle_to(get_global_mouse_position())
			get_parent().add_child(bullet_instance)

			# Set sound and play
			if audio_stream_player_2d.stream != SHOOT_11:
				audio_stream_player_2d.stream = SHOOT_11
			audio_stream_player_2d.play()

		else:
			# Out of ammo sound
			if audio_stream_player_2d.stream != NO_BULLET:
				audio_stream_player_2d.stream = NO_BULLET
			audio_stream_player_2d.play()

func handle_jump():
	if is_on_floor(): 
		
		air_jump = true  # Allow air jump again when landing

	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY

	elif not is_on_floor():
		# Cut jump short if released early
		if Input.is_action_just_released("jump") and velocity.y < JUMP_VELOCITY / 2:
			
			velocity.y = JUMP_VELOCITY / 2
		
		# Double jump only if air_jump is still true
		if Input.is_action_just_pressed("jump") and air_jump and not just_wall_jumped:
			
			velocity.y = JUMP_VELOCITY * 0.8
			air_jump = false  # 🔑 Prevent further jumps until landing


func handle_wall_jump():
	if not is_on_wall_only(): return
	var wall_normal = get_wall_normal()
	if wall_jump_timer.time_left > 0 :
		wall_normal = was_wall_normal
	if Input.is_action_just_pressed("move_left") and wall_normal == Vector2.LEFT:
		velocity.x = wall_normal.x * SPEED
		velocity.y = JUMP_VELOCITY
		just_wall_jumped = true
	if Input.is_action_just_pressed("move_right") and wall_normal == Vector2.RIGHT:
		velocity.x = wall_normal.x * SPEED
		velocity.y = JUMP_VELOCITY
		just_wall_jumped = true

func get_hit(from_position: Vector2) -> void:
	if is_invulnerable:
		return
		
	ammo = max(ammo - 2, 0)
	remove_gumballs(1)
	
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

func enter_shop():
	tower_interact_container.visible = true

func exit_shop():
	tower_interact_container.visible = false
	
func addGumball():
	gumballs += 1
	match gumballs:
		1:
			gumball.visible = true
		2:
			gumball_2.visible = true
		3:
			gumball_3.visible = true
	
	
func remove_gumballs(used_gumballs):
	gumballs = max(0, gumballs - used_gumballs)
	match gumballs:
		0:
			gumball.visible = false
			gumball_2.visible = false
			gumball_3.visible = false
		1:
			gumball_2.visible = false
			gumball_3.visible = false
		2:
			gumball_3.visible = false

	
