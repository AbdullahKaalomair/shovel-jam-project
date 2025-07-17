extends StaticBody2D

var gumball_spawn_num: int
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
		emit_signal("givePoint", 3)
		emit_signal("playerPickUp", gumball_spawn_num)
		body.addGumball()
		queue_free()
