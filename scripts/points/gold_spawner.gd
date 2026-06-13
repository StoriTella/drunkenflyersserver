extends RigidBody2D
class_name CoinSpawner

@export var coin_scene: PackedScene = preload("res://scenes/points/gold.tscn")
@export var min_angle: float = -60.0
@export var max_angle: float = -120.0
@export var gravity_scale_coins: float = 0.1
@export var spawn_rect_size: Vector2 = Vector2(20, 20)

@export var min_speed: float = 100
@export var max_speed: float = 200

# Genéricos
@export var point_min_vel = 200
@export var point_max_vel = 300
@export var coin_type: PointsTypeEnum.PointsType = PointsTypeEnum.PointsType.GOLD_SPAWNER
@export var points: int = 0
@export var point_delay: float = 1.5
@export var expiration_date: float = 10.0
@export var spawn_interval: float = 0.1

var spawn_timer: float = 0.0

func _ready():
	await get_tree().create_timer(expiration_date).timeout
	queue_free()

func initialize(start_pos: Vector2):
	position = start_pos

func _process(delta):
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_coin()

func spawn_coin():
	if not coin_scene:
		return
	var coin = coin_scene.instantiate()
	var offset = Vector2(randf_range(-spawn_rect_size.x, spawn_rect_size.x), randf_range(-spawn_rect_size.y, spawn_rect_size.y))
	coin.position = global_position + offset
	
	var angle = deg_to_rad(randf_range(min_angle, max_angle))
	var speed = randf_range(min_speed, max_speed)
	var velocity = Vector2(cos(angle), sin(angle)) * speed
	
	if coin is RigidBody2D:
		coin.linear_velocity = velocity
		coin.gravity_scale = gravity_scale_coins
	
	get_parent().add_child(coin)
