extends CharacterBody2D

@export var attack_cooldown: float = 0.5

@export var missile_scene: PackedScene
@export var missile_burst_count: int = 20
@export var missile_burst_interval: float = 0.25

@export var random_missile_count: int = 100
@export var random_missile_interval: float = 0.2
@export var random_missile_loop: bool = true
@export var random_missile_color: Color = Color(0.2, 1.0, 0.8)

@export var ring_missile_count: int = 100
@export var ring_gap_degrees: float = 50.0
@export var ring_chance: float = 1.0 / 2.0

@export var laser_scene: PackedScene
@export var laser_telegraph_duration: float = 1.2
@export var laser_active_duration: float = 0.3
@export var laser_length: float = 2000.0
@export var laser_count: int = 6
@export var laser_spread_degrees: float = 60.0
@export var laser_width: float = 18.0
@export var laser_stagger: float = 0.06

@export var enemy_scenes: Array[PackedScene] = []
@export var enemy_spawn_count: int = 2500
@export var enemy_spawn_radius: float = 800.0
@export var max_enemies_on_screen: int = 5000

@export var death_shake_strength: float = 250.0

enum AttackType { HOMING_MISSILES, LASER, SPAWN }
enum State { IDLE, ATTACKING }
var state: State = State.IDLE

var player: Node2D
var attack_timer: float = 0.0
var random_missile_loop_active: bool = false

var is_vulnerable: bool = false
var vulnerable_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	attack_timer = attack_cooldown
	if random_missile_loop:
		_start_random_missile_loop()
	add_to_group("boss")


func _physics_process(delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("player")
		if not player:
			player = get_tree().root.find_child("Triangle", true, false)
		if not player:
			return

	if state == State.IDLE:
		attack_timer -= delta
		if attack_timer <= 0.0:
			_start_random_attack()

func _start_random_attack() -> void:
	state = State.ATTACKING
	var available: Array = [AttackType.HOMING_MISSILES, AttackType.LASER]
	if enemy_scenes.size() > 0:
		available.append(AttackType.SPAWN)
	var attack: AttackType = available.pick_random()
	match attack:
		AttackType.HOMING_MISSILES: _do_homing_missile_attack()
		AttackType.LASER:           _do_laser_attack()
		AttackType.SPAWN:           _do_spawn_attack()


func _end_attack() -> void:
	state = State.IDLE
	attack_timer = attack_cooldown


func _do_homing_missile_attack() -> void:
	for i in missile_burst_count:
		await get_tree().create_timer(missile_burst_interval).timeout
		_fire_homing_missile()
	_end_attack()


func _fire_homing_missile() -> void:
	if not missile_scene:
		return
	var missile: Node2D = missile_scene.instantiate()
	get_tree().current_scene.add_child(missile)
	missile.global_position = global_position
	if missile.has_method("set_target"):
		missile.set_target(player)


func _start_random_missile_loop() -> void:
	random_missile_loop_active = true
	_random_missile_loop_tick()


func _random_missile_loop_tick() -> void:
	if not random_missile_loop_active or not is_inside_tree():
		return

	if randf() < ring_chance:
		await _fire_ring_missiles()
	else:
		for i in random_missile_count:
			await get_tree().create_timer(random_missile_interval).timeout
			if not is_inside_tree():
				return
			_fire_random_missile()

	await get_tree().create_timer(attack_cooldown).timeout
	if is_inside_tree():
		_random_missile_loop_tick()


func _fire_random_missile() -> void:
	if not missile_scene:
		return
	var missile: Node2D = missile_scene.instantiate()
	get_tree().current_scene.add_child(missile)
	missile.global_position = global_position
	var random_angle: float = randf() * TAU
	var random_dir: Vector2 = Vector2.from_angle(random_angle)
	missile.rotation = random_angle
	missile.set("move_direction", random_dir)
	if missile.has_method("set_target"):
		missile.set_target(null)
	_tint_missile(missile, random_missile_color)
	_exclude_enemies_from_missile(missile)


func _fire_ring_missiles() -> void:
	if not missile_scene:
		return

	var gap_start: float = randf() * TAU
	var gap_half: float = deg_to_rad(ring_gap_degrees * 0.5)
	var step: float = TAU / float(ring_missile_count)

	for i in ring_missile_count:
		var angle: float = step * i
		var angle_diff: float = abs(wrapf(angle - gap_start, -PI, PI))
		if angle_diff < gap_half:
			continue

		var missile: Node2D = missile_scene.instantiate()
		get_tree().current_scene.add_child(missile)
		missile.global_position = global_position
		var dir: Vector2 = Vector2.from_angle(angle)
		missile.rotation = angle
		missile.set("move_direction", dir)
		if missile.has_method("set_target"):
			missile.set_target(null)
		_tint_missile(missile, Color(1.0, 0.3, 0.0))
		_exclude_enemies_from_missile(missile)

	await get_tree().create_timer(0.1).timeout


func _tint_missile(missile: Node2D, color: Color) -> void:
	missile.modulate = color


func _exclude_enemies_from_missile(missile: Node2D) -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if missile is PhysicsBody2D and enemy is PhysicsBody2D:
			missile.add_collision_exception_with(enemy)
			enemy.add_collision_exception_with(missile)


func _do_laser_attack() -> void:
	if not player or not laser_scene:
		_end_attack()
		return

	var base_direction: Vector2 = (player.global_position - global_position).normalized()
	var base_angle: float = base_direction.angle()

	var angles: Array = []
	if laser_count == 1:
		angles.append(base_angle)
	else:
		var spread: float = deg_to_rad(laser_spread_degrees)
		for i in laser_count:
			var t: float = float(i) / float(laser_count - 1)
			angles.append(base_angle + lerp(-spread, spread, t) + randf_range(-deg_to_rad(8), deg_to_rad(8)))

	for angle in angles:
		var laser: Node2D = laser_scene.instantiate()
		get_tree().current_scene.add_child(laser)
		laser.telegraph_duration = laser_telegraph_duration
		laser.active_duration = laser_active_duration
		laser.length = laser_length
		laser.width = laser_width
		laser.setup(self, Vector2.from_angle(angle), player)
		laser.fire()
		await get_tree().create_timer(laser_stagger).timeout

	_end_attack()


func _do_spawn_attack() -> void:
	var current_enemy_count: int = get_tree().get_nodes_in_group("enemy").size()
	var available_slots: int = max_enemies_on_screen - current_enemy_count

	if available_slots <= 0:
		_end_attack()
		return

	var spawn_count: int = min(enemy_spawn_count, available_slots)

	for i in spawn_count:
		var scene: PackedScene = enemy_scenes.pick_random()
		if not scene:
			continue
		var enemy: Node2D = scene.instantiate()
		get_tree().current_scene.add_child(enemy)
		var angle: float = randf() * TAU
		enemy.global_position = global_position + Vector2.from_angle(angle) * enemy_spawn_radius
		add_collision_exception_with(enemy)
		enemy.add_collision_exception_with(self)
	_end_attack()

func die() -> void:
	random_missile_loop_active = false
	_shake_camera_hard()
	queue_free()


func _shake_camera_hard() -> void:
	var camera := get_viewport().get_camera_2d()
	if camera and camera.has_method("trigger_shake"):
		camera.trigger_shake(death_shake_strength)
