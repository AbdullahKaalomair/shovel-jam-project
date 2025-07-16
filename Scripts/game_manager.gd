extends Node

var money = 20
var round = 1
var enemy_number = 5
var enemy_spawned = 0
var enemy_killed = 0
var enemy_spawn_point = randi_range(1, 4)
var tower_location = 0

@onready var gumball_machine: Tower = $"../GumballMachine"
@onready var player: Player = $"../Player"
@onready var ammo_number_label: Label = $"../CanvasLayer/ResourceContainer/MarginContainer/GridContainer/AmmoNumberLabel"
@onready var point_number_label: Label = $"../CanvasLayer/ResourceContainer/MarginContainer/GridContainer/PointNumberLabel"
@onready var wave_number_label: Label = $"../CanvasLayer/ResourceContainer/MarginContainer/GridContainer/WaveNumberLabel"
@onready var result_label: Label = $"../CanvasLayer/ResultContainer/VBoxContainer/ResultLabel"
@onready var enemy_spawn_timer: Timer = $"../Timers/EnemySpawnTimer"
@onready var round_start_timer: Timer = $"../Timers/RoundStartTimer"
@onready var result_container: PanelContainer = $"../CanvasLayer/ResultContainer"


@onready var spawn_1: Node2D = $"../enemySpawnPoints/Spawn 1"
@onready var spawn_2: Node2D = $"../enemySpawnPoints/Spawn 2"
@onready var spawn_3: Node2D = $"../enemySpawnPoints/Spawn 3"
@onready var spawn_4: Node2D = $"../enemySpawnPoints/Spawn 4"

@onready var tower_spawn_0: Node2D = $"../towerSpawnPoints/Spawn 0"
@onready var tower_spawn_1: Node2D = $"../towerSpawnPoints/Spawn 1"
@onready var tower_spawn_2: Node2D = $"../towerSpawnPoints/Spawn 2"
@onready var tower_spawn_3: Node2D = $"../towerSpawnPoints/Spawn 3"
@onready var tower_spawn_4: Node2D = $"../towerSpawnPoints/Spawn 4"



const PEPPERMINT_CANDY_ENEMY = preload("res://Scenes/Enemies/PeppermintCandyEnemy.tscn")

func _on_enemy_give_point(point: Variant) -> void:
	money += point
	
	
func _process(delta: float) -> void:
	ammo_number_label.text = str(player.ammo)
	point_number_label.text = str(money)
	wave_number_label.text = str(round)
	
	if not gumball_machine:
		result_container.visible = true
		result_label.text = "You lose"
		enemy_spawn_timer.stop()
		
func nextWave():
	if round < 3:
		enemy_spawn_timer.stop()
		round_start_timer.start()
		round += 1
		enemy_number += 5
		tower_location = randi_range(0, 4)
		match tower_location:
			0:
				gumball_machine.position = tower_spawn_0.position
			1:
				gumball_machine.position = tower_spawn_1.position
			2:
				gumball_machine.position = tower_spawn_2.position
			3:
				gumball_machine.position = tower_spawn_3.position
			4:
				gumball_machine.position = tower_spawn_4.position
	else:
		result_container.visible = true
	
func losePoints(points: int):
	money = max(0, money - points)
	
func _on_enemy_spawn_timer_timeout() -> void:
	if enemy_spawned <= enemy_number:
		
		enemy_spawn_point = randi_range(1, 4)
		#To ensure the enemy doesnt spawn where the tower is
		while enemy_spawn_point == tower_location:
			enemy_spawn_point = randi_range(1, 4)
		
		var enemy = PEPPERMINT_CANDY_ENEMY.instantiate()
		enemy.target = gumball_machine
		match enemy_spawn_point:
			1:
				enemy.position = spawn_1.position
			2:
				enemy.position = spawn_2.position
			3:
				enemy.position = spawn_3.position
			4:
				enemy.position = spawn_4.position
		add_child(enemy)
		enemy.givePoint.connect(_on_enemy_give_point)
		enemy.death.connect(_on_enemy_death)
		enemy_spawned += 1
		
		

func _on_enemy_death():
	enemy_killed += 1
	if enemy_killed == enemy_number + 1:
		nextWave()


func _on_round_start_timer_timeout() -> void:
	enemy_spawn_timer.start()


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()
