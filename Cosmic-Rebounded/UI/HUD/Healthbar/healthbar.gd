extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar = $DamageBar

# The set thingy just makes it so that way whenever a different script
# sets the health to something, then the _set_health function gets called
var health = 0 : set = _set_health

func _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health

	# Taking Damage.
	if health < prev_health:
		timer.start()
	# Healing or Increasing.
	else:
		damage_bar.value = health
		

func init_health(_health):
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health
	

# Could lerp this for smoother transition.
func _on_timer_timeout() -> void:
	damage_bar.value = health
