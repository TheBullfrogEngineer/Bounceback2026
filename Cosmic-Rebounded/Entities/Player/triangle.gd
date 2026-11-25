extends CharacterBody2D

@export var camera: Camera2D
@export var speed = 750.0
@export var dash_speed = 1050
@export var friction = 200
@export var bounce_speed_retention = 0.9
@export var max_hp: int = 100
@export var enemy_scene: PackedScene
@onready var spawn_location: PathFollow2D = $Path2D/PathFollow2D
@onready var healthbar = $HUD/Healthbar
@export var bounce_lock_duration = 0.2
var bounce_lock = false

@export var vulnerable_knockback_force: float = 1400.0
@export var vulnerable_knockback_lock_duration: float = 0.3
@export var vulnerable_invuln_duration: float = 1.5
var knockback_lock = false

var hp: int = max_hp
var dashing = false
var direction: Vector2 = Vector2.ZERO
var dash_direction: Vector2 = Vector2.RIGHT
var can_move = true
var can_dash = true

@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var bounce_sound: AudioStreamPlayer2D = $BounceSound
const STUN_SOUNDS := [
	preload("res://Assets/Audio/SFX/Player/sfx_player_damaged.wav"),
	preload("res://Assets/Audio/SFX/Player/sfx_player_stunned.wav"),
]


func _ready() -> void:
	add_to_group("player")
	hp = max_hp
	healthbar.init_health(hp)
	dir = (get_global_mouse_position() - global_position).normalized()

var dir = Vector2.ZERO
var input = "a"

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:

	if not bounce_lock:
		if dir != Vector2.ZERO:
			rotation = lerp_angle(rotation, dir.angle(), 20 * delta)


@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	var controller_dir := Input.get_vector("left", "right", "up", "down")
	if controller_dir != Vector2.ZERO and (input == "a" or input == "c"):
		dir = controller_dir
	elif input == "a" or input == "m":
		dir = (get_global_mouse_position() - global_position).normalized()
	if Input.is_action_just_pressed("dash") and can_dash and can_move:
		dashing = true
		dash_direction = dir
		rotation = dash_direction.angle()
		$DashSound.play()
		can_dash = false
		$dash_timer.start()
		$dash_cooldown.start()
		

	if can_move:
		if Input.is_action_pressed("propel"):
				velocity = speed * dir
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		if dashing:
			velocity = dash_speed * dash_direction
			$Sprite2D.animation = "supermodedash"
		elif knockback_lock:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		elif bounce_lock:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	else:
		velocity = Vector2.ZERO

	var collision := move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal()) * bounce_speed_retention
		dash_direction = velocity.normalized()
		rotation = dash_direction.angle()
		dashing = false
		bounce_lock = true
		$%Effects.play("Bounce")
		_play_bounce()
		get_tree().create_timer(bounce_lock_duration).timeout.connect(func(): bounce_lock = false)
	var impact_velocity := velocity
	move_and_slide()
	_handle_wall_collisions()
	#Check this for slide bounce


func _handle_wall_collisions() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		var normal := collision.get_normal()
		
		if collider and collider.is_in_group("enemy"):
			velocity = velocity.bounce(normal) * bounce_speed_retention
			dash_direction = velocity.normalized()
			rotation = dash_direction.angle()
			_play_bounce()
			if dashing:
				_kill_enemy(collider)
			else:
				take_damage(1)
		break

func _play_bounce() -> void:
	if bounce_sound.stream:
		camera.trigger_shake()
		bounce_sound.play()

func _kill_enemy(enemy: Node) -> void:
	%Effects.play("Kill")
	var origin: Vector2 = enemy.global_position
	if enemy.has_method("die"):
		enemy.die()
	else:
		enemy.queue_free()

func take_damage(amount: int) -> void:

	camera.trigger_shake()
	Sfx.play(STUN_SOUNDS.pick_random())
	hp -= amount
	if hp <= -1:
		get_tree().paused = true
	healthbar.health = hp
	

func apply_vulnerable_knockback(away_direction: Vector2) -> void:

	dashing = false
	knockback_lock = true
	velocity = away_direction.normalized() * vulnerable_knockback_force
	rotation = away_direction.angle()
	camera.trigger_shake()
	Sfx.play(STUN_SOUNDS.pick_random())

	sprite.modulate.a = 0.5

	get_tree().create_timer(vulnerable_knockback_lock_duration).timeout.connect(func(): knockback_lock = false)

	await get_tree().create_timer(vulnerable_invuln_duration).timeout
	sprite.modulate.a = 1.0

func _on_dash_timer_timeout() -> void:
	dashing = false
	$Sprite2D.animation = "dash"

func _on_dash_cooldown_timeout() -> void:
	can_dash = true
	
	
	#
	#
	#
	#
	# Add yo-yo feature (Upgrade)
	#
	#
	#
	#


func _on_enemy_spawn_timer_timeout() -> void:
	if enemy_scene == null:
		return
	spawn_location.progress_ratio = randf()
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_location.global_position
	get_tree().current_scene.add_child(enemy)
