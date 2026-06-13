extends RigidBody2D

class_name TumbleweedBall

@export var speed: float = 150.0
@export var base_ball_damage = 10
@export var rotation_speed: float = 5.0

@export var expiration_date: float = 20.0

var direction: Vector2 = Vector2.RIGHT

@export var margin_teleport: float = 200.0
#GENERIC
@export var type_ball: BallTypeEnum.BallType = BallTypeEnum.BallType.TUMBLEWEED
@export var ball_min_vel = 200
@export var ball_max_vel = 400
@export var ball_delay: float = 1.0

func _ready():
	await get_tree().create_timer(expiration_date).timeout
	queue_free()

func initialize(start_pos: Vector2, end_pos: Vector2, ball_speed: float):
	position = start_pos
	speed = ball_speed
	
	direction = (end_pos - start_pos).normalized()
	linear_velocity = direction * speed
	
	if 0 > direction.x:
		rotation_speed = -rotation_speed

func _physics_process(delta):
	rotation += rotation_speed * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.can_be_damaged():
			on_hit_player(body)

func on_hit_player(body):
	body.hit_by_tumbleweed_ball(base_ball_damage, margin_teleport)
	queue_free()
