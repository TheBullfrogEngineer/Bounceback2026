
extends CharacterBody2D

@export var speed = 750.0
@export var dash_speed = 1750
@export var friction = 500
@export var bounce_speed_retention = 1.2
@export var stun_duration = 0.5
@export var max_hp: int = 3
var planet_counter = 0
var bounce_count = 0

@export var bounce_lock_duration = 0.2
var hp: int = max_hp
var dashing = false
var direction: Vector2 = Vector2.ZERO
var dash_direction: Vector2 = Vector2.RIGHT
var can_move = true
var can_dash = true
var bounce_lock = false
@export var enemy_scene: PackedScene # Drag your enemy.tscn here in the Inspector
@onready var spawn_location: PathFollow2D = $EnemySpawnPath/SpawnLocation
@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	hp = max_hp
	sprite.play("idle")
	add_to_group("player")

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if velocity.length() > 1.0:
		rotation = lerp_angle(rotation, velocity.angle(), 20 * delta)

func _physics_process(delta: float) -> void:
	$Camera2D/Control/Label.text = "Planet Counter " + str(planet_counter) 
	$Camera2D/Control/Label2.text = "Hit Points " + str(hp)
	if Input.is_action_just_pressed("dash") and can_dash:
		dashing = true
		dash_direction = (get_global_mouse_position() - global_position).normalized()
		rotation = dash_direction.angle()
		$AnimatedSprite2D/Sprite2D.visible = true
		$dash_timer.start()

	if can_move:
		if dashing:
			velocity = dash_speed * dash_direction
		elif bounce_lock:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		else:
			if Input.is_action_pressed("propel"):
				#var dir = (get_global_mouse_position() - global_position).normalized()
				#velocity = speed * dir
				pass
			else:
				velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	_handle_wall_collisions()

	if dashing:
		var collision := move_and_collide(velocity * delta)
		if collision:
			var collider := collision.get_collider()
			if collider and collider.is_in_group("enemy"):
				_kill_enemy(collider)
			else:
				velocity = velocity.bounce(collision.get_normal()) * bounce_speed_retention
				dash_direction = velocity.normalized()
				rotation = dash_direction.angle()
				dashing = false
				bounce_lock = true
				get_tree().create_timer(bounce_lock_duration).timeout.connect(func(): bounce_lock = false)
	else:
		move_and_slide()
		_handle_wall_collisions()

	_update_animation()


func _update_animation() -> void:
	if velocity.length() > 1.0:
		if sprite.animation != "moving":
			sprite.play("moving")
	else:
		if sprite.animation != "idle":
			sprite.play("idle")


func _handle_wall_collisions() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		var normal := collision.get_normal()

		if collider and collider.is_in_group("enemy"):
			if dashing:
				_kill_enemy(collider)
			elif not dashing:
				take_damage(1)
			continue

		if dashing:
			velocity = velocity.bounce(normal) * bounce_speed_retention
			dash_direction = velocity.normalized()
			rotation = dash_direction.angle()

		if collider and collider.is_in_group("enemy"):
			_kill_enemy(collider)
			continue

		velocity = velocity.bounce(normal) * bounce_speed_retention
		dash_direction = velocity.normalized()
		rotation = dash_direction.angle()


func _kill_enemy(enemy: Node) -> void:
	if enemy.has_method("die"):
		enemy.die()
	else:
		enemy.queue_free()
func addplanet(amount: int) -> void:
	planet_counter += amount
	if planet_counter == 10:
		print("you win")

func take_damage(amount: int) -> void:
	hp -= amount
	print("HP: ", hp)

	if hp <= 0:
		print("game over!")
		get_tree().reload_current_scene()


func _on_dash_timer_timeout() -> void:
	dashing = false
	$AnimatedSprite2D/Sprite2D.visible = false


func hazard_kill() -> void:
	global_position = Vector2.ZERO
	velocity = Vector2.ZERO
	dashing = false


func _on_timer_timeout() -> void:
	if enemy_scene == null:
		return
	# 1. Pick a random point along the Path2D perimeter
	spawn_location.progress_ratio = randf()
	# 2. Instantiate the enemy
	var enemy = enemy_scene.instantiate()
	# 3. Set its global position to the random point
	enemy.global_position = spawn_location.global_position
	# 4. Add the enemy to the main game world (NOT as a child of the player)
	get_tree().current_scene.add_child(enemy)
