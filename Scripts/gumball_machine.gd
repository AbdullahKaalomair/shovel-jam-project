extends StaticBody2D
class_name Tower
var max_health = 10
var health = max_health
var damage_sources := {}
var damage_timer := 0.0
const DAMAGE_INTERVAL := 1.0  # damage every 1 second

var playerIn = false
@export var score: Node
@export var player: Node2D

@onready var hp_bar: ProgressBar = $UIControl/HealthBar
@onready var sprite: Sprite2D = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp_bar.max_value = max_health
	hp_bar.value = health
	hp_bar.get("theme_override_styles/fill").texture.pause = false


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
		
	if playerIn and Input.is_action_just_pressed("interact") and score.money > 3:
		player.ammo += 3
		score.money -= 3

func take_damage(damage: int):
	health -= damage
	hp_bar.value = health
	if health % 2 == 0:
		sprite.frame -= 1
	if health <= 0:
		queue_free()
	
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.name)
	if body is Enemy:
		damage_sources[body] = body.damage
		body.inTowerSwitch()
	
	if body is Player:
		playerIn = true
		body.enter_tower()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Enemy:
		damage_sources.erase(body)
		body.inTowerSwitch()
	
	if body is Player:
		playerIn = false
		body.exit_tower()
	
