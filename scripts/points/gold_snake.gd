extends RigidBody2D
class_name GoldSnake

@export var speed: float = 80.0
@export var direction_change_interval: float = 3.0
@export var gold_coin_scene: PackedScene = preload("res://scenes/points/gold.tscn")
@export var lifetime: float = 15.0

# Genéricos
@export var point_min_vel = 200
@export var point_max_vel = 300
@export var coin_type: PointsTypeEnum.PointsType = PointsTypeEnum.PointsType.GOLD_SNAKE
@export var points: int = 0
@export var point_delay: float = 1.0
@export var expiration_date: float = 15.0
@export var spawn_interval: float = 0.05

var direction: Vector2 = Vector2.RIGHT
var change_dir_timer: float = 0.0
var spawn_timer: float = 0.0

func _ready():
	await get_tree().create_timer(expiration_date).timeout
	queue_free()

func initialize(start_pos: Vector2, points_speed: float):
	position = start_pos
	speed = points_speed
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	linear_velocity = direction * speed

func _physics_process(delta):
	change_dir_timer += delta
	if change_dir_timer >= direction_change_interval:
		change_dir_timer = 0.0
		direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		linear_velocity = direction * speed
	
	# spawn de moedas de ouro
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		create_gold()

func change_direction():
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	linear_velocity = direction * speed

func create_gold():
	if not gold_coin_scene:
		return
	var gold = gold_coin_scene.instantiate()
	gold.position = global_position
	get_parent().add_child(gold)
