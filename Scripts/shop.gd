extends Control

@onready var game_manager: Node = $"../../GameManager"
@onready var gumball_machine: Tower = $"../../GumballMachine"
@onready var player: Player = $"../../Player"

@onready var shop: Control = $"."
@onready var tower_hp_button: Button = $ShopContainer/MarginContainer/GridContainer/TowerHPButton
@onready var ammo_button: Button = $ShopContainer/MarginContainer/GridContainer/AmmoButton
@onready var speed_button: Button = $ShopContainer/MarginContainer/GridContainer/SpeedButton

var speed_boost_price = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func open_shop() -> void:
	player.can_shoot = false
	shop.visible = true
	if game_manager.money >= 50:
		tower_hp_button.disabled = false
		
	if game_manager.money >= 10:
		ammo_button.disabled = false
	
	if game_manager.money >= speed_boost_price:
		speed_button.disabled = false
	

func _on_tower_hp_button_pressed() -> void:
	gumball_machine.increase_max_hp()
	game_manager.losePoints(50)
	if game_manager.money < 50:
		tower_hp_button.disabled = true


func _on_exit_button_pressed() -> void:
	shop.visible = false
	player.can_shoot = true


func _on_ammo_button_pressed() -> void:
	player.ammo += 50
	game_manager.losePoints(10)
	if game_manager.money < 10:
		ammo_button.disabled = true


func _on_speed_button_pressed() -> void:
	player.SPEED += 100
	game_manager.losePoints(speed_boost_price)
	if game_manager.money < speed_boost_price:
		speed_button.disabled = true
