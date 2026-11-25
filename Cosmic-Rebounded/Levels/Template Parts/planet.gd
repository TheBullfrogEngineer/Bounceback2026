extends Node2D

@onready var pyrax = $AnimatedSprite2D

func _ready():
	pyrax.play("default")
