extends Node

@onready var label = $CanvasLayer/Label

var time_left: float = 30.0
var expired: bool = false

func _ready() -> void:
	add_to_group("time_left")

func time_left_to_live():
	var minutes = floor(max(time_left, 0.0)/60)
	var sec = int(max(time_left, 0.0)) % 60
	if time_left <= 0:
		_restart_level()
	return [minutes,sec]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if expired:
		return
	time_left -= delta
	label.text = "SURVIVE: " + "%02d:%02d" % time_left_to_live()

func _restart_level() -> void:
	if expired:
		return
	expired = true
	#Replace this with cutscene
	get_tree().paused = true
