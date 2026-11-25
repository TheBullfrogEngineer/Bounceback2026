extends Node2D

var player

@onready var pyrax = $Area2D/AnimatedSprite2D

func _ready() -> void:
	pyrax.play("default")


func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name != "Triangle":
		return
	else:
		get_tree().change_scene_to_file.call_deferred("res://Levels/pyrax.tscn")
