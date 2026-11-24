extends CharacterBody2D

@export var camera: Camera2D
@export var speed = 750.0
@export var dash_speed = 1050
@export var friction = 200
@export var bounce_speed_retention = 1.5
@export var max_hp: int = 3

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
		$Duration.start()
		

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
		$%Effects.play("Bounce")
		_play_bounce()
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

func apply_vulnerable_knockback(away_direction: Vector2) -> void:
	knockback_lock = true
	velocity = away_direction.normalized() * vulnerable_knockback_force
	rotation = away_direction.angle()
	camera.trigger_shake()
	Sfx.play(STUN_SOUNDS.pick_random())

	
	
	#
	#
	#
	#
	# Add yo-yo feature (Upgrade)
	#
	#
	#
	#

func _on_duration_timeout() -> void:
	dashing = false
	$Sprite2D.animation = "dash"
