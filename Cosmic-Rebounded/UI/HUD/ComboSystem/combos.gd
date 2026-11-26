extends Control

@export var player: CharacterBody2D
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready():
	$Label.visible = false

func start_combo():
	$"../../combo_timer".start()
	$Label.visible = true
	$Label.text = str("X", player.combo, "!")
	


func _on_combo_timer_timeout() -> void:
	$Label.visible = false
	player.combo = 0
