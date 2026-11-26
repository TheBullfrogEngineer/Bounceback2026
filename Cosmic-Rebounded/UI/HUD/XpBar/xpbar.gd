extends ProgressBar

@onready var level_label = $Label
@onready var xp_label = $Label2

var max = 100.0
var min = 0.0
var level
var xp = 0 : set = add_xp
var level_value
# Called when the node enters the scene tree for the first time.



func _ready() -> void:
	value = Levelmanager.init_xp()
	level = Levelmanager.init_levels()
	level_label.text = str(level)
	xp_label.text = str(value)

func add_xp(amount):
	level_value = Levelmanager.add_xp(amount)
	level = level_value[0]
	value = level_value[1]
	level_label.text = str(level)
	xp_label.text = str(value)
