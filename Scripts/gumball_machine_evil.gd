extends Tower
class_name Tower_Enemy

var teleport_threshold = max_health/5
var damage_to_teleport = 0

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hit_timer: Timer = $HitTimer

const EVIL_BULLET = preload("res://Scenes/evil_bullet.tscn")

signal teleport
signal death

func take_damage(damage: int):
	health -= damage
	damage_to_teleport += damage
	hp_bar.value = health
	activate_hit_shader_effect()
	sprite_handle()
	if health <= 0:
		emit_signal("death")
	if damage_to_teleport >= teleport_threshold:
		collision_shape_2d.disabled = true
		await sink_and_shake()
		emit_signal("teleport")
		collision_shape_2d.disabled = false

func heal_tower_gumballs(gumballs: int):
	var used_gumballs = 0 
	emit_signal("givePoint", 25)
	take_damage(5)
	used_gumballs += 1
	sprite_handle()
	return used_gumballs

func activate_hit_shader_effect() -> void:
	sprite.material.set_shader_parameter("active", true)
	hit_timer.start()

func _on_shoot_timer_timeout() -> void:
	var shoot_point = get_node("ShootPoint").get_global_position()
	var player_pos = player.global_position
	var direction = player_pos - shoot_point
	var angle = direction.angle()

	var bullet_instance = EVIL_BULLET.instantiate()
	bullet_instance.position = shoot_point
	bullet_instance.rotation = angle
	get_parent().add_child(bullet_instance)


func _on_hit_timer_timeout() -> void:
	sprite.material.set_shader_parameter("active", false)
