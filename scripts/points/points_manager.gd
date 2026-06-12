extends Node

@export var points_scenes: Array[PackedScene] = [
	preload("res://scenes/points/coin.tscn"),
	preload("res://scenes/points/gold.tscn")
]
@export var margin = 50

var game_server: Node2D
var screen_size: Vector2
var power_up_speed: float = 0.0
var spawning: bool = false
var spawn_timer: float = 0.0
var current_points_type: PointsTypeEnum.PointsType
var current_points_scene: PackedScene = null

func _ready():
	await get_tree().process_frame
	game_server = get_parent()
	screen_size = get_viewport().get_visible_rect().size
	select_random_points()

func _process(delta):
	if not spawning:
		return
	
	spawn_timer += delta
	var current_delay = get_points_delay()
	if spawn_timer >= current_delay:
		spawn_timer = 0.0
		spawn_points()

func start_spawning():
	spawning = true

func stop_spawning():
	spawning = false

func select_random_points() -> PackedScene:
	if points_scenes.is_empty():
		return null
	
	var random_index = randi() % points_scenes.size()
	current_points_scene = points_scenes[random_index]
	return current_points_scene

func spawn_points():
	var selected_scene = select_random_points()
	if selected_scene == null:
		return
	
	var spawn_pos = GenericPositions.get_random_position_in_screen(margin)
	
	var points = selected_scene.instantiate()
	points.position = spawn_pos
	
	if points.has_method("initialize"):
		points.initialize(spawn_pos, spawn_pos)
	
	add_child(points)

func remove_points(points):
	if points and is_instance_valid(points):
		points.queue_free()


func get_points_delay():
	var instance = current_points_scene.instantiate()
	var delay = instance.point_delay
	instance.queue_free()
	return delay

func _on_timer_timeout() -> void:
	select_random_points()
