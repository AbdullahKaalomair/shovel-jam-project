extends StaticBody2D

var gumball_spawn_num: int
@onready var area_2d: Area2D = $Area2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

signal playerPickUp(gumball_spawn_num)
signal givePoint(point)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and body.gumballs < 3:
		self.hide()
		emit_signal("givePoint", 5)
		emit_signal("playerPickUp", gumball_spawn_num)
		body.addGumball()
		area_2d.monitoring = false
		audio_stream_player_2d.play()
		await audio_stream_player_2d.finished
		queue_free()
