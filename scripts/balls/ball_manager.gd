extends Node

class_name BallManager

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var timer: Timer = $Timer

@export var ball_scenes: Array[PackedScene] = [
	preload("res://scenes/balls/base_ball.tscn"),
	preload("res://scenes/balls/bomb_ball.tscn"),
	preload("res://scenes/balls/boomerang_ball.tscn"),
	preload("res://scenes/balls/balao_sao_joao_ball.tscn"),
	preload("res://scenes/balls/anvil_ball.tscn"),
	preload("res://scenes/balls/polen_ball.tscn"),
	preload("res://scenes/balls/tumbleweed_ball.tscn"),
]

var game_server: Node2D
var spawning: bool = false
var current_ball_scenes: Array[PackedScene] = []
var spawn_timers: Array[float] = []

func _ready():
	await get_tree().process_frame
	game_server = get_parent()
	select_random_ball_type()
	spawn_timers.resize(current_ball_scenes.size())
	for i in range(spawn_timers.size()):
		spawn_timers[i] = 0.0

func _process(delta):
	if not spawning:
		return
		
	if timer.is_stopped():
		timer.start()
	
	for i in range(current_ball_scenes.size()):
		spawn_timers[i] += delta
		var delay = get_ball_delay(current_ball_scenes[i])
		
		if spawn_timers[i] >= delay:
			spawn_timers[i] = 0.0
			spawn_balls(i)

func get_ball_delay(ball_scene):
	var instance = ball_scene.instantiate()
	var delay = instance.ball_delay
	instance.queue_free()
	return delay

func select_random_ball_type():
	if ball_scenes.is_empty():
		return
	
	music_player.play()
	current_ball_scenes.clear()
	
	var shuffled = ball_scenes.duplicate()
	shuffled.shuffle()
	
	for i in range(min(2, shuffled.size())):
		current_ball_scenes.append(shuffled[i])
	
	print("Ball types: ", current_ball_scenes.size())

func get_ball_min_vel(ball_scene):
	var instance = ball_scene.instantiate()
	var ball_min_vel = instance.ball_min_vel
	instance.queue_free()
	return ball_min_vel

func get_ball_max_vel(ball_scene):
	var instance = ball_scene.instantiate()
	var ball_max_vel = instance.ball_max_vel
	instance.queue_free()
	return ball_max_vel

func start_spawning():
	spawning = true

func stop_spawning():
	spawning = false

func remove_ball(ball):
	if ball and is_instance_valid(ball):
		ball.queue_free()

func _on_timer_timeout() -> void:
	select_random_ball_type()


#Spawn balls
func spawn_balls(index: int):
	var ball_scene = current_ball_scenes[index]
	var ball_instance = ball_scene.instantiate()
	var ball_type = ball_instance.type_ball
	ball_instance.queue_free()
	
	match ball_type:
		BallTypeEnum.BallType.NORMAL:
			default_ball_trajectory(ball_scene)
		BallTypeEnum.BallType.BOMB:
			default_ball_trajectory(ball_scene)
		BallTypeEnum.BallType.BOOMERANG:
			default_ball_trajectory(ball_scene)
		BallTypeEnum.BallType.BALAOSAOJOAO:
			balao_sao_joao_trajectory(ball_scene)
		BallTypeEnum.BallType.ANVIL:
			anvil_trajectory(ball_scene)
		BallTypeEnum.BallType.POLEN:
			polen_trajectory(ball_scene)
		BallTypeEnum.BallType.TUMBLEWEED:
			tumbleweed_trajectory(ball_scene)

func default_ball_trajectory(ball_scene):
	
	var pos_array = GenericPositions.get_random_position_outside_screen_with_target()
	var spawn_pos = pos_array.spawn
	var target_pos = pos_array.target
	
	var random_speed = randf_range(get_ball_min_vel(ball_scene), get_ball_max_vel(ball_scene))
	
	var ball = ball_scene.instantiate()
	ball.initialize(spawn_pos, target_pos, random_speed)
	
	add_child(ball)

func anvil_trajectory(ball_scene):
	var spawn_pos = GenericPositions.get_position_above_screen(50)
	var random_speed = randf_range(get_ball_min_vel(ball_scene), get_ball_max_vel(ball_scene))
	
	var ball = ball_scene.instantiate()
	ball.initialize(spawn_pos, random_speed)
	
	add_child(ball)

func balao_sao_joao_trajectory(ball_scene):
	var spawn_pos = GenericPositions.get_position_below_screen(50)
	var random_speed = randf_range(get_ball_min_vel(ball_scene), get_ball_max_vel(ball_scene))
	
	var ball = ball_scene.instantiate()
	ball.initialize(spawn_pos, random_speed)
	
	add_child(ball)

func polen_trajectory(ball_scene):
	var spawn_pos = GenericPositions.get_random_position_in_screen(50)
	var random_speed = randf_range(get_ball_min_vel(ball_scene), get_ball_max_vel(ball_scene))
	
	var ball = ball_scene.instantiate()
	ball.initialize(spawn_pos, random_speed)
	
	add_child(ball)
	
func tumbleweed_trajectory(ball_scene):
	var pos_array = GenericPositions.get_position_side_to_side(50)
	var spawn_pos = pos_array.spawn
	var target_pos = pos_array.target
	
	var random_speed = randf_range(get_ball_min_vel(ball_scene), get_ball_max_vel(ball_scene))
	
	var ball = ball_scene.instantiate()
	ball.initialize(spawn_pos, target_pos, random_speed)
	
	add_child(ball)
