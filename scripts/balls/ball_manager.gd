extends Node

class_name BallManager

@onready var music_player: AudioStreamPlayer = $MusicPlayer

@export var ball_scenes: Array[PackedScene] = [
	preload("res://scenes/balls/base_ball.tscn"),
	preload("res://scenes/balls/bomb_ball.tscn")
]

var game_server: Node2D
var spawning: bool = false
var current_ball_type: BallTypeEnum.BallType
var current_ball_scene: PackedScene = null
var spawn_timer: float = 0.0

func _ready():
	await get_tree().process_frame
	game_server = get_parent()
	select_random_ball_type()

func _process(delta):
	if not spawning:
		return
	
	spawn_timer += delta
	var current_delay = get_ball_delay()
	if spawn_timer >= current_delay:
		spawn_timer = 0.0
		spawn_ball()

func get_ball_delay():
	var instance = current_ball_scene.instantiate()
	var delay = instance.ball_delay
	instance.queue_free()
	return delay

func select_random_ball_type():
	if ball_scenes.is_empty():
		return
	
	music_player.play()
	current_ball_type = randi() % ball_scenes.size()
	current_ball_scene = ball_scenes[current_ball_type]
	print("Ball type changed to: ", current_ball_scene.resource_path)

func spawn_ball():
	if current_ball_scene == null:
		return
	
	var pos_array = GenericPositions.get_random_position_outside_screen_with_target()
	var spawn_pos = pos_array.spawn
	var target_pos = pos_array.target
	
	var random_speed = randf_range(get_ball_min_vel(),get_ball_max_vel())
	
	var ball = current_ball_scene.instantiate()
	ball.initialize(spawn_pos, target_pos, random_speed)
	
	add_child(ball)

func get_ball_min_vel():
	var instance = current_ball_scene.instantiate()
	var ball_min_vel = instance.ball_min_vel
	instance.queue_free()
	return ball_min_vel

func get_ball_max_vel():
	var instance = current_ball_scene.instantiate()
	var ball_max_vel = instance.ball_max_vel
	instance.queue_free()
	return ball_max_vel

func start_spawning():
	spawning = true
	spawn_timer = 0.0

func stop_spawning():
	spawning = false

func remove_ball(ball):
	if ball and is_instance_valid(ball):
		ball.queue_free()

func _on_timer_timeout() -> void:
	select_random_ball_type()
