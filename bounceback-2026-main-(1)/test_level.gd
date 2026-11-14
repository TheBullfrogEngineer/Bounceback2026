extends Node2D

var player
# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_first_node_in_group("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	if body == player:
		player.addplanet(1)
		$Planet.position = Vector2(randf_range(0,13306.0), randf_range(-10000, 0))
