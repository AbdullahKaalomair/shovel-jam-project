extends Control

var game_scene = "res://Scenes/game.tscn"
var tutorial_scene = ""
var options_scene = ""

var is_start_animation_playing = false
var is_game_started = false
var is_credits_being_watched = false

@onready var menu_container = $MenuMarginContainer
@onready var credits_container = $CreditsMarginContainer
@onready var start_container = $StartMarginContainer
@onready var bg_audio_player = $BGAudioStreamPlayer
@onready var se_audio_player = $SEAudioStreamPlayer
@onready var anim_player = $AnimationPlayer
@onready var machine_light = $MenuObjects/MachineLight
@onready var text_light = $MenuObjects/TextLight
@onready var canvas_modulate = $MenuObjects/CanvasModulate

var menu_music = preload("res://Assets/Sounds/Menu/Christmas synths.ogg")
var coin_se = preload("res://Assets/Sounds/Menu/Coins5.mp3")
var crank_se = preload("res://Assets/Sounds/Menu/crank.mp3")

var base_energy = 1.2
var flicker_range = 0.2

func _ready() -> void:
	menu_container.visible = false
	start_container.visible = true
	credits_container.visible = false
	canvas_modulate.visible = true
	machine_light.visible = true
	text_light.visible = true

func _input(event: InputEvent) -> void:
	if not is_start_animation_playing and event.is_pressed():
		is_start_animation_playing = true
		anim_player.play("Start_Machine")
	elif not is_game_started and is_start_animation_playing and event.is_pressed():
		skip_animation()
		is_game_started = true
	else:
		if is_credits_being_watched and event.is_action_pressed("ui_cancel"):
			end_credits()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(game_scene)


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file(tutorial_scene)


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file(options_scene)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	credits_container.visible = true
	is_credits_being_watched = true


func _on_scroll_container_end_reached() -> void:
	end_credits()


func _on_light_flicker_timer_timeout() -> void:
	var random_energy = randf_range(-flicker_range, flicker_range)
	machine_light.energy = base_energy + random_energy
	text_light.energy = base_energy + random_energy


func end_credits() -> void:
	credits_container.visible = false
	is_credits_being_watched = false

func play_coin_noise() -> void:
	se_audio_player.stream = coin_se
	se_audio_player.play()

func play_crank_noise() -> void:
	se_audio_player.stream = crank_se
	se_audio_player.play()

func start_pressed() -> void:
	menu_container.visible = true
	start_container.visible = false
	bg_audio_player.stream = menu_music
	bg_audio_player.play()
	canvas_modulate.visible = false
	machine_light.visible = false
	text_light.visible = false
	is_game_started = true

func skip_animation() -> void:
	var anim_name = anim_player.current_animation
	var length = anim_player.get_animation(anim_name).length
	anim_player.seek(length, true)
