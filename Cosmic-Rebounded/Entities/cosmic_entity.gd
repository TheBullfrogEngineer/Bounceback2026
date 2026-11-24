extends CharacterBody2D


var player
var camera
var speed: float = 1065.0
var can_damage = true
#@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	#sprite.play("idle")
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")
	camera = get_tree().get_first_node_in_group("camera")
	
func _physics_process(delta: float) -> void:
	var direction = (player.global_position-global_position).normalized()
	velocity = lerp(velocity, direction * speed, 8.5 * delta)
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player:
		if player.dashing:
			die()
		else:
			if can_damage:
				player.take_damage(1)
				can_damage = false
				$Timer.start()
		
func die():
	camera.trigger_shake()
	queue_free()


func _on_timer_timeout() -> void:
	can_damage = true
