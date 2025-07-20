extends Control

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

func _ready():
	play_fade_out()

func play_fade_out() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished

func play_fade_in() -> void:
	animation_player.play("fade_in")
	await animation_player.animation_finished
