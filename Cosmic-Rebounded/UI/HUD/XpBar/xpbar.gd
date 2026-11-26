extends ProgressBar

@onready var level_label = $Label
@onready var xp_label = $Label2

var max = 100.0
var min = 0.0
var level
var xp = 0 : set = add_xp
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = min
	level = 0
	print(level)
	level_label.text = str(level)
	xp_label.text = str(value)

func add_xp(amount):
	value += amount
	if value >= 100.0:
		value = (value - 100)
		level += 1
		print(level)
		level_label.text = str(level)
	xp_label.text = str(value)
