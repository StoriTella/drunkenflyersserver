extends Node

class_name BallManager

@export var base_ball_scene: PackedScene = preload("res://scenes/balls/base_ball.tscn")
@export var ball_min_vel = 100
@export var ball_max_vel = 400

var game_server: Node2D
var spawning: bool = false
var normal_ball_timer: float = 0.0
var normal_ball_delay: float = 1.0

func _ready():
	await get_tree().process_frame
	game_server = get_parent()

func _process(delta):
	if not spawning:
		return
	normal_ball_timer += delta
	if normal_ball_timer >= normal_ball_delay:
		normal_ball_timer = 0.0
		spawn_normal_ball()

func start_spawning():
	spawning = true

func stop_spawning():
	spawning = false

func spawn_normal_ball():
	if base_ball_scene == null:
		print("base_ball_scene null!")
		return
	
	var pos_array = GenericPositions.get_random_position_outside_screen_with_target()
	var spawn_pos = pos_array.spawn
	var target_pos = pos_array.target
	
	var random_speed = randf_range(ball_min_vel, ball_max_vel)
	
	var ball = base_ball_scene.instantiate()
	ball.initialize(spawn_pos, target_pos, random_speed)
	
	add_child(ball)
	
	return ball

func remove_ball(ball):
	if ball and is_instance_valid(ball):
		ball.queue_free()
