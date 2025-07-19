extends StaticBody2D
class_name Tower

var max_health = 10.0
var health = 10
var damage_sources := {}
var damage_timer := 0.0
const DAMAGE_INTERVAL := 1.0  # damage every 1 second

var playerIn = false
@export var player: Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var hp_bar: ProgressBar = $UIControl/HealthBar
@onready var sprite: Sprite2D = $Sprite

@onready var can_shoot = false

const BULLET = preload("res://Scenes/bullet.tscn")

signal givePoint(point)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp_bar.max_value = max_health
	hp_bar.value = health
	hp_bar.get("theme_override_styles/fill").texture.pause = false
	sprite_handle()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if damage_sources.size() > 0:
		damage_timer += delta
		if damage_timer >= DAMAGE_INTERVAL:
			for damage in damage_sources:
				take_damage(damage_sources[damage])
			damage_timer = 0.0
	else:
		damage_timer = 0.0  # reset when not overlapping
		
	

func sprite_handle():
	
	var bar_per_sprite = ceil(max_health/5.0)
	var bar = bar_per_sprite
	var desired_sprite = 1
	while bar <= health:
		desired_sprite = min(5, desired_sprite + 1)
		bar += bar_per_sprite
	sprite.frame = desired_sprite


func sink_and_shake() -> void:

	animation_player.play("sink_and_shake")
	await animation_player.animation_finished
	animation_player.play("RESET")
	return


func take_damage(damage: int):
	health -= damage
	hp_bar.value = health
	#if health % 2 == 0:
		#sprite.frame -= 1
	sprite_handle()
	if health <= 0:
		queue_free()

func heal_tower_gumballs(gumballs: int):
	var used_gumballs = 0 
	for gumball in gumballs:
				if health != max_health:
					emit_signal("givePoint", 25)
					health = min(max_health, health + int(max_health/4))
					used_gumballs += 1
	hp_bar.value = health
	hp_bar.max_value = max_health
	sprite_handle()
	return used_gumballs

func increase_max_hp():
	max_health += 5
	health = max_health
	hp_bar.value = health
	hp_bar.max_value = max_health
	sprite_handle()

func _on_shoot_timer_timeout() -> void:
	if can_shoot and damage_sources.size() > 0:
		var shoot_point = get_node("ShootPoint").get_global_position()
		var enemy_pos = damage_sources.keys()[0].position
		var direction = enemy_pos - shoot_point
		var angle = direction.angle()

		var bullet_instance = BULLET.instantiate()
		bullet_instance.position = shoot_point
		bullet_instance.rotation = angle
		get_parent().add_child(bullet_instance)
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Enemy:
		damage_sources[body] = body.damage
		body.inTowerSwitch()
	
	if body is Player:
		if body.gumballs > 0:
			var used_gumballs = heal_tower_gumballs(body.gumballs)
			body.remove_gumballs(used_gumballs)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Enemy:
		damage_sources.erase(body)
		body.inTowerSwitch()
	
