extends Node

var money = 20
var round = 1
const FINAL_ROUND = 6
var enemy_number = 5
var enemy_spawned = 0
var enemy_killed = 0
var enemy_spawn_point = randi_range(1, 4)
var enemy_chosen = 2

var tower_location = randi_range(1,4)
var gumball_location = randi_range(1,8)
var gumball_spawned = []
var maximum_gumball_number = 5

@onready var gumball_machine: Tower = $"../GumballMachine"
@onready var gumball_machine_evil: Tower_Enemy = $"../GumballMachine_Evil"
@onready var player: Player = $"../Player"

@onready var ammo_number_label: Label = $"../CanvasLayer/ResourceContainer/MarginContainer/GridContainer/AmmoNumberLabel"
@onready var point_number_label: Label = $"../CanvasLayer/ResourceContainer/MarginContainer/GridContainer/PointNumberLabel"
@onready var wave_number_label: Label = $"../CanvasLayer/ResourceContainer/MarginContainer/GridContainer/WaveNumberLabel"
@onready var result_label: Label = $"../CanvasLayer/ResultContainer/VBoxContainer/ResultLabel"
@onready var time_left_label: Label = $"../CanvasLayer/TimerContainer/CenterContainer/TimeLeftLabel"

@onready var enemy_spawn_timer: Timer = $"../Timers/EnemySpawnTimer"
@onready var round_start_timer: Timer = $"../Timers/RoundStartTimer"
@onready var gumball_spawn_timer: Timer = $"../Timers/GumballSpawnTimer"
@onready var end_the_world_timer: Timer = $"../Timers/EndTheWorldTimer"

@onready var result_container: PanelContainer = $"../CanvasLayer/ResultContainer"
@onready var wave_container: PanelContainer = $"../CanvasLayer/WaveContainer"
@onready var wave_label: Label = $"../CanvasLayer/WaveContainer/CenterContainer/MarginContainer/WaveLabel"
@onready var timer_container: PanelContainer = $"../CanvasLayer/TimerContainer"

@onready var audio_stream_player: AudioStreamPlayer = $"../AudioStreamPlayer"


@onready var pause_menu: Control = $"../CanvasLayer/PauseMenu"
var paused = false

@onready var spawn_1: Node2D = $"../enemySpawnPoints/Spawn 1"
@onready var spawn_2: Node2D = $"../enemySpawnPoints/Spawn 2"
@onready var spawn_3: Node2D = $"../enemySpawnPoints/Spawn 3"
@onready var spawn_4: Node2D = $"../enemySpawnPoints/Spawn 4"

@onready var tower_spawn_0: Node2D = $"../towerSpawnPoints/Spawn 0"
@onready var tower_spawn_1: Node2D = $"../towerSpawnPoints/Spawn 1"
@onready var tower_spawn_2: Node2D = $"../towerSpawnPoints/Spawn 2"
@onready var tower_spawn_3: Node2D = $"../towerSpawnPoints/Spawn 3"
@onready var tower_spawn_4: Node2D = $"../towerSpawnPoints/Spawn 4"

@onready var gumball_spawn_1: Node2D = $"../GumballSpawnPoints/Spawn 1"
@onready var gumball_spawn_2: Node2D = $"../GumballSpawnPoints/Spawn 2"
@onready var gumball_spawn_3: Node2D = $"../GumballSpawnPoints/Spawn 3"
@onready var gumball_spawn_4: Node2D = $"../GumballSpawnPoints/Spawn 4"
@onready var gumball_spawn_5: Node2D = $"../GumballSpawnPoints/Spawn 5"
@onready var gumball_spawn_6: Node2D = $"../GumballSpawnPoints/Spawn 6"
@onready var gumball_spawn_7: Node2D = $"../GumballSpawnPoints/Spawn 7"
@onready var gumball_spawn_8: Node2D = $"../GumballSpawnPoints/Spawn 8"

const PEPPERMINT_CANDY_ENEMY = preload("res://Scenes/Enemies/PeppermintCandyEnemy.tscn")
const WRAPPED_CANDY_ENEMY = preload("res://Scenes/Enemies/wrapped_candy_enemy.tscn")
const GUMBALL = preload("res://Scenes/gumball.tscn")

func _on_enemy_give_point(point: Variant) -> void:
	money += point
	
func _ready():
	gumball_spawn_timer.wait_time = randi_range(5, 20)
	gumball_spawn_timer.start()
	
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

func _process(delta: float) -> void:
	ammo_number_label.text = str(player.ammo)
	point_number_label.text = str(money)
	wave_number_label.text = str(round)
	
	if not gumball_machine:
		result_container.visible = true
		result_label.text = "You lose"
		enemy_spawn_timer.stop()
		get_tree().paused = true
	
	if round == FINAL_ROUND:
		var t = int(end_the_world_timer.time_left)
		var minutes = t / 60
		var seconds = t % 60
		time_left_label.text = "%02d:%02d" % [minutes, seconds]
	
	if Input.is_action_just_pressed("pause"):
		pause()

func nextWave():
	round += 1
	if round < FINAL_ROUND:
		show_wave_message()
		enemy_spawn_timer.stop()
		round_start_timer.start()
		enemy_number += 5
		teleport_tower()
		enemy_spawn_timer.wait_time -= 0.4
		enemy_spawned = 0
		enemy_killed = 0
	else:
		#result_container.visible = true
		print("LAST WAVE")
		wave_label.text = "THE END OF THE WORLD JUST GOT STARTED BY THE MACHINE"
		show_wave_message()
		gumball_machine.hide()
		timer_container.show()
		end_the_world_timer.start()
		teleport_tower()
		maximum_gumball_number = 3
		for gumball_spawn_num in gumball_spawned:
			_on_gumball_player_pickup(gumball_spawn_num)
		
		
func teleport_tower():
	tower_location = randi_range(1, 4)
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
	player.red_arrow.visible = true
	if round == FINAL_ROUND:
		round_start_timer.start()
		gumball_machine_evil.position  = gumball_machine.position

func losePoints(points: int):
	money = max(0, money - points)
	
func show_wave_message():
	wave_container.modulate.a = 0.0
	wave_container.show()

	var tween = create_tween()

	# Fade in
	tween.tween_property(wave_container, "modulate:a", 1.0, 1.0)
	
	# Wait visible for 2 seconds
	tween.tween_interval(2.0)
	
	# Fade out
	tween.tween_property(wave_container, "modulate:a", 0.0, 1.0)

	# Optionally hide after
	tween.tween_callback(wave_container.hide)

func pause():
	if paused:
		pause_menu.hide()
		get_tree().paused = false
	else:
		get_tree().paused = true
		pause_menu.show()
		
	paused = !paused
	
func win():
	result_container.visible = true
	
func _on_enemy_spawn_timer_timeout() -> void:
	if enemy_spawned <= enemy_number:
		
		enemy_chosen = randi_range(1,2)
		enemy_spawn_point = randi_range(1, 4)
		#To ensure the enemy doesnt spawn where the tower is
		while enemy_spawn_point == tower_location:
			enemy_spawn_point = randi_range(1, 4)
			
		var enemy
		match enemy_chosen:
			1:
				enemy = PEPPERMINT_CANDY_ENEMY.instantiate()
			2:
				enemy = WRAPPED_CANDY_ENEMY.instantiate()

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

func _on_gumball_player_pickup(gumball_spawn_num):
	gumball_spawned.erase(gumball_spawn_num)

func _on_round_start_timer_timeout() -> void:
	player.red_arrow.visible = false
	if round == 1 or round >= FINAL_ROUND:
		return
	enemy_spawn_timer.start()


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_gumball_spawn_timer_timeout() -> void:
	if gumball_spawned.size() <= maximum_gumball_number:
		
		while gumball_spawned.has(gumball_location):
			gumball_location = randi_range(1, 8)
		#To ensure the enemy doesnt spawn where the tower is
		var gumball = GUMBALL.instantiate()
		gumball.gumball_spawn_num = gumball_location
		match gumball_location:
			1:
				gumball.position = gumball_spawn_1.position
			2:
				gumball.position = gumball_spawn_2.position
			3:
				gumball.position = gumball_spawn_3.position
			4:
				gumball.position = gumball_spawn_4.position
			5:
				gumball.position = gumball_spawn_5.position
			6:
				gumball.position = gumball_spawn_6.position
			7:
				gumball.position = gumball_spawn_7.position
			8:
				gumball.position = gumball_spawn_8.position
		add_child(gumball)
		gumball.givePoint.connect(_on_enemy_give_point)
		gumball.playerPickUp.connect(_on_gumball_player_pickup)
		gumball_spawned.append(gumball_location)
	gumball_spawn_timer.wait_time = randi_range(5, 20)
	gumball_spawn_timer.start()


func _on_audio_stream_player_finished() -> void:
	audio_stream_player.play()

func _on_end_the_world_timer_timeout() -> void:
	get_tree().paused = true
	result_container.visible = true
	result_label.text = "You lose"
