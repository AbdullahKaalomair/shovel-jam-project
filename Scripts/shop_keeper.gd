extends StaticBody2D

var playerIn = false

@export var shop: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playerIn and Input.is_action_just_pressed("interact"):
		shop.open_shop()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.enter_shop()
		playerIn = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		body.exit_shop()
		playerIn = false
