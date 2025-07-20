extends Control

@onready var game_manager: Node = $"../../GameManager"
@onready var gumball_machine: Tower = $"../../GumballMachine"
@onready var gumball_machine_evil: Tower_Enemy = $"../../GumballMachine_Evil"
@onready var player: Player = $"../../Player"
@onready var audio_stream_player_2d: AudioStreamPlayer = $AudioStreamPlayer2D


@onready var shop: Control = $"."
@onready var tower_hp_button: Button = $ShopContainer/MarginContainer/GridContainer/TowerHPButton
@onready var ammo_button: Button = $ShopContainer/MarginContainer/GridContainer/AmmoButton
@onready var speed_button: Button = $ShopContainer/MarginContainer/GridContainer/SpeedButton
@onready var turret_button: Button = $ShopContainer/MarginContainer/GridContainer/TurretButton

var speed_boost_price = 200
var has_speed_boost = false
var turret_upgrade_price = 300


func open_shop() -> void:
	player.can_shoot = false
	shop.visible = true
	update_buttons()

func _on_tower_hp_button_pressed() -> void:
	audio_stream_player_2d.play()
	gumball_machine.increase_max_hp()
	game_manager.losePoints(50)
	
	update_buttons()


func _on_exit_button_pressed() -> void:
	shop.visible = false
	player.can_shoot = true


func _on_ammo_button_pressed() -> void:
	audio_stream_player_2d.play()
	player.ammo += 50
	game_manager.losePoints(10)
	
	update_buttons()


func _on_speed_button_pressed() -> void:
	audio_stream_player_2d.play()
	player.SPEED += 100
	has_speed_boost = true
	game_manager.losePoints(speed_boost_price)
	
	update_buttons()


func _on_turret_button_pressed() -> void:
	audio_stream_player_2d.play()
	gumball_machine.can_shoot = true
	gumball_machine_evil.can_shoot = true
	game_manager.losePoints(turret_upgrade_price)
	
	update_buttons()

func update_buttons():
	if game_manager:
		tower_hp_button.disabled = game_manager.money < 50
		speed_button.disabled = game_manager.money < speed_boost_price or has_speed_boost
		ammo_button.disabled = game_manager.money < 10
		turret_button.disabled = game_manager.money < turret_upgrade_price or gumball_machine.can_shoot
