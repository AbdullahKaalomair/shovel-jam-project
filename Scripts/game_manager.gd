extends Node

var money = 20
var total_points = 0
var round = 1
var FINAL_ROUND = 2
var endless 
var enemy_number = 5
var enemy_spawned = 0
var enemy_killed = 0
var enemy_spawn_point = randi_range(1, 4)
var enemy_chosen = 2

var tower_location = randi_range(1,4)
var tower_location_prev = 0
var gumball_location = randi_range(1,8)
var gumball_spawned = []
var maximum_gumball_number = 5

@onready var gumball_machine: Tower = $"../GumballMachine"
@onready var gumball_machine_evil: Tower_Enemy = $"../GumballMachine_Evil"
@onready var player: Player = $"../Player"

#labels
@onready var ammo_number_label: Label = $"../CanvasLayer/ResourceContainer/MarginContainer/GridContainer/AmmoNumberLabel"
@onready var point_number_label: Label = $"../CanvasLayer/ResourceContainer/MarginContainer/GridContainer/PointNumberLabel"
@onready var wave_number_label: Label = $"../CanvasLayer/ResourceContainer/MarginContainer/GridContainer/WaveNumberLabel"
@onready var result_label: Label = $"../CanvasLayer/ResultContainer/VBoxContainer/ResultLabel"
@onready var time_left_label: Label = $"../CanvasLayer/TimerContainer/CenterContainer/TimeLeftLabel"

#timers
@onready var enemy_spawn_timer: Timer = $"../Timers/EnemySpawnTimer"
@onready var round_start_timer: Timer = $"../Timers/RoundStartTimer"
@onready var gumball_spawn_timer: Timer = $"../Timers/GumballSpawnTimer"
@onready var end_the_world_timer: Timer = $"../Timers/EndTheWorldTimer"

#canvas layer elements
@onready var result_container: PanelContainer = $"../CanvasLayer/ResultContainer"
@onready var wave_container: PanelContainer = $"../CanvasLayer/WaveContainer"
@onready var wave_label: Label = $"../CanvasLayer/WaveContainer/CenterContainer/MarginContainer/WaveLabel"
@onready var timer_container: PanelContainer = $"../CanvasLayer/TimerContainer"
@onready var fade_layer: Control = $"../CanvasLayer/fadeLayer"


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

const HAPPY = preload("res://Assets/Sounds/Music/happy.mp3")
const X = preload("res://Assets/Sounds/X.ogg")
const VAST_PLACES_LOOPING = preload("res://Assets/Sounds/Menu/Vast-Places_Looping.mp3")
const VICTORY = preload("res://Assets/Sounds/Music/Victory.ogg")
const MENU = "res://Scenes/menu.tscn"

func _on_enemy_give_point(point: Variant) -> void:
	money += point
	total_points += point
	
func _ready():
	endless = GameSettings.endless_mode_enabled
	if endless:
		FINAL_ROUND = 999999999999999999
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
		lose()
	
	if not endless:
		if round == FINAL_ROUND:
			var t = int(end_the_world_timer.time_left)
			var minutes = t / 60
			var seconds = t % 60
			time_left_label.text = "%02d:%02d" % [minutes, seconds]
	else:
		if round % 5 == 0:
			var t = int(end_the_world_timer.time_left)
			var minutes = t / 60
			var seconds = t % 60
			time_left_label.text = "%02d:%02d" % [minutes, seconds]
	
	if Input.is_action_just_pressed("pause"):
		pause()

func nextWave():
	round += 1
	if not endless:
		if round < FINAL_ROUND:
			show_wave_message()
			enemy_spawn_timer.stop()
			await gumball_machine.sink_and_shake()
			teleport_tower()
			round_start_timer.start()
			enemy_number += 5
			enemy_spawn_timer.wait_time -= 0.3
			enemy_spawned = 0
			enemy_killed = 0
		else:
			#result_container.visible = true
			wave_label.text = "THE END OF THE WORLD JUST GOT STARTED BY THE MACHINE"
			show_wave_message()
			enemy_spawn_timer.stop()
			audio_stream_player.stream = X
			audio_stream_player.play()
			await gumball_machine.sink_and_shake()
			gumball_machine.hide()
			timer_container.show()
			end_the_world_timer.start()
			gumball_machine_evil.update_hp(gumball_machine.health, gumball_machine.max_health)
			teleport_tower()
			maximum_gumball_number = 3
			for gumball_spawn_num in gumball_spawned:
				_on_gumball_player_pickup(gumball_spawn_num)
				
	elif round % 5 == 0:
		wave_label.text = "THE END OF THE WORLD JUST GOT STARTED BY THE MACHINE"
		show_wave_message()
		enemy_spawn_timer.stop()
		audio_stream_player.stream = X
		audio_stream_player.play()
		await gumball_machine.sink_and_shake()
		gumball_machine.hide()
		timer_container.show()
		end_the_world_timer.start()
		gumball_machine_evil.update_hp(gumball_machine.health, gumball_machine.max_health)
		teleport_tower()
	else:
		wave_label.text = "Prepare the MACHINE for the next wave..."
		show_wave_message()
		enemy_spawn_timer.stop()
		await gumball_machine.sink_and_shake()
		teleport_tower()
		round_start_timer.start()
		enemy_number += 3
		enemy_spawn_timer.wait_time = max (0.2 , enemy_spawn_timer.wait_time - 0.3)
		enemy_spawned = 0
		enemy_killed = 0
		
		
		
func teleport_tower():
	tower_location_prev = tower_location
	while tower_location_prev == tower_location:
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
	if not endless:
		if round == FINAL_ROUND:
			round_start_timer.start()
			gumball_machine_evil.position  = gumball_machine.position
	elif round % 5 == 0:
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
	if not endless:
		result_container.modulate.a = 0.0  # Start fully transparent
		result_container.visible = true

		result_label.text = "YOU SAVED THE WORLD \nTotal points: " + str(total_points)
		end_the_world_timer.stop()
		audio_stream_player.stream = VICTORY
		audio_stream_player.autoplay = false
		audio_stream_player.play()
		
		# Start fade-in tween
		var tween := get_tree().create_tween()
		tween.tween_property(result_container, "modulate:a", 1.0, 0.5) # Fade in over 1.5 sec
		await tween.finished
		get_tree().paused = true
	else:
		end_the_world_timer.stop()
		end_the_world_timer.wait_time = 120
		timer_container.hide()
		audio_stream_player.stream = HAPPY
		audio_stream_player.play()
		nextWave()
		gumball_machine.show()
		gumball_machine_evil.position.x = 3987.0
		gumball_machine_evil.resurrect()

func lose():
	
	result_container.visible = true
	result_container.modulate.a = 0.0  # Start fully transparent
	
	if not endless:
		result_label.text = "You lose \nTotal points: " +  str(total_points)
	else:
		result_label.text = "Game Over! \nTotal points: " +  str(total_points) + "\nWave reached: " + str(round)
	
	enemy_spawn_timer.stop()
	audio_stream_player.stream = VAST_PLACES_LOOPING
	audio_stream_player.play()
	
	# Start fade-in tween
	var tween := get_tree().create_tween()
	tween.tween_property(result_container, "modulate:a", 1.0, 0.5) # Fade in over 1.5 sec
	await tween.finished
	
	get_tree().paused = true
	
func _on_enemy_spawn_timer_timeout() -> void:
	if enemy_spawned <= enemy_number:
		
		if (round <= 3):
			enemy_chosen = 1
		else:
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
	if enemy_killed >= enemy_number + 1:
		nextWave()

func _on_gumball_player_pickup(gumball_spawn_num):
	gumball_spawned.erase(gumball_spawn_num)

func _on_round_start_timer_timeout() -> void:
	player.red_arrow.visible = false
	if round == 1 or round >= FINAL_ROUND:
		return
	enemy_spawn_timer.start()


func _on_restart_button_pressed() -> void:
	await fade_layer.play_fade_in()
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
	lose()


func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU)


func _on_gumball_machine_death() -> void:
	lose()
