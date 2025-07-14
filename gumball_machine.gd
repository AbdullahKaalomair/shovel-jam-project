extends StaticBody2D
class_name Tower
var health = 5
var damage_sources := {}
var damage_timer := 0.0
const DAMAGE_INTERVAL := 1.0  # damage every 1 second

var playerIn = false
@export var score: Node
@export var player: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
		
	if Input.is_action_just_pressed("interact") and score.money > 3 and playerIn:
		player.ammo += 10
		score.money -= 3

func take_damage(damage: int):
	print(damage)
	print(health)
	health -= damage
	if health <= 0:
		queue_free()
	
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.name)
	if body is Enemy:
		damage_sources[body] = body.damage
	
	if body is Player:
		playerIn = true



func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Enemy:
		damage_sources.erase(body)
	
	if body is Player:
		playerIn = false
	
