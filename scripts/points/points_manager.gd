extends Node

@onready var timer: Timer = $Timer
@onready var timer_difficulty: Timer = $DifficultyTimer

@export var points_scenes: Array[PackedScene] = [
	preload("res://scenes/points/coin.tscn"),
	preload("res://scenes/points/gold.tscn"),
	preload("res://scenes/points/gold_snake.tscn"),
	preload("res://scenes/points/gold_spawner.tscn"),
	preload("res://scenes/points/diamond.tscn"),
]
@export var margin = 50

@export var n_spawns_points: int = 1
var game_server: Node2D
var screen_size: Vector2
var spawning: bool = false
var current_points_scenes: Array[PackedScene] = []
var spawn_timers: Array[float] = []

func _ready():
	await get_tree().process_frame
	game_server = get_parent()
	screen_size = get_viewport().get_visible_rect().size
	select_random_points()
	spawn_timers.resize(current_points_scenes.size())
	for i in range(spawn_timers.size()):
		spawn_timers[i] = 0.0

func _process(delta):
	if not spawning:
		return
	
	if timer.is_stopped():
		timer.start()
	
	if timer_difficulty.is_stopped():
		timer_difficulty.start()
	
	for i in range(spawn_timers.size()):
		spawn_timers[i] += delta
		var delay = get_points_delay(current_points_scenes[i])
		
		if spawn_timers[i] >= delay:
			spawn_timers[i] = 0.0
			spawn_points(i)

func get_points_delay(points_scene: PackedScene) -> float:
	var instance = points_scene.instantiate()
	var delay = instance.point_delay
	instance.queue_free()
	return delay

func select_random_points():
	if points_scenes.is_empty():
		return
	
	spawn_timers.resize(current_points_scenes.size())
	for i in range(spawn_timers.size()):
		spawn_timers[i] = 0.0
	
	current_points_scenes.clear()
	
	var shuffled = points_scenes.duplicate()
	shuffled.shuffle()
	
	for i in range(min(n_spawns_points, shuffled.size())):
		current_points_scenes.append(shuffled[i])
	
	print("Points types: ", current_points_scenes.size())

func start_spawning():
	spawning = true

func stop_spawning():
	spawning = false

func default_points(points_scene):
	var spawn_pos = GenericPositions.get_random_position_in_screen(margin)
	var points = points_scene.instantiate()
	points.initialize(spawn_pos)
	add_child(points)

func snake_points(points_scene):
	var spawn_pos = GenericPositions.get_random_position_in_screen(margin)
	var points = points_scene.instantiate()
	var random_speed = randf_range(get_points_min_vel(points_scene), get_points_max_vel(points_scene))
	points.initialize(spawn_pos, random_speed)
	add_child(points)

func get_points_min_vel(points_scene):
	var instance = points_scene.instantiate()
	var point_min_vel = instance.point_min_vel
	instance.queue_free()
	return point_min_vel

func get_points_max_vel(points_scene):
	var instance = points_scene.instantiate()
	var point_max_vel = instance.point_max_vel
	instance.queue_free()
	return point_max_vel

func _on_timer_timeout() -> void:
	select_random_points()

func _on_difficulty_timer_timeout() -> void:
	n_spawns_points += 1
	select_random_points()

func spawn_points(index: int):
	var points_scene = current_points_scenes[index]
	var points_instance = points_scene.instantiate()
	var points_type = points_instance.coin_type
	points_instance.queue_free()
	match points_type:
		PointsTypeEnum.PointsType.COIN:
			default_points(points_scene)
		PointsTypeEnum.PointsType.GOLD:
			default_points(points_scene)
		PointsTypeEnum.PointsType.GOLD_SNAKE:
			snake_points(points_scene)
		PointsTypeEnum.PointsType.GOLD_SPAWNER:
			default_points(points_scene)
		PointsTypeEnum.PointsType.DIAMOND:
			default_points(points_scene)
