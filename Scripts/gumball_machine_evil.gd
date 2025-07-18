extends Tower
class_name Tower_Enemy

var teleport_threshold = max_health/5
var damage_to_teleport = 0

const EVIL_BULLET = preload("res://Scenes/evil_bullet.tscn")

signal teleport
signal death

func take_damage(damage: int):
	health -= damage
	damage_to_teleport += damage
	hp_bar.value = health
	sprite_handle()
	if health <= 0:
		emit_signal("death")
	if damage_to_teleport >= teleport_threshold:
		emit_signal("teleport")

func heal_tower_gumballs(gumballs: int):
	var used_gumballs = 0 
	emit_signal("givePoint", 25)
	take_damage(5)
	used_gumballs += 1
	sprite_handle()
	return used_gumballs


func _on_shoot_timer_timeout() -> void:
	var shoot_point = get_node("ShootPoint").get_global_position()
	var player_pos = player.global_position
	var direction = player_pos - shoot_point
	var angle = direction.angle()

	var bullet_instance = EVIL_BULLET.instantiate()
	bullet_instance.position = shoot_point
	bullet_instance.rotation = angle
	get_parent().add_child(bullet_instance)
