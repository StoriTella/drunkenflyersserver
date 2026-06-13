extends RigidBody2D

class_name AnvilBall

@export var speed: float = 200.0
@export var base_ball_damage = 30

@export var ball_timer: float = 0.0

#GENERIC
@export var type_ball: BallTypeEnum.BallType = BallTypeEnum.BallType.ANVIL
@export var ball_min_vel = 0
@export var ball_max_vel = 0
@export var ball_delay: float = 1.5

@export var expiration_date: float = 8.0

var spawned_position: Vector2

func _ready():
	await get_tree().create_timer(expiration_date).timeout
	queue_free()

func initialize(start_pos: Vector2, ball_speed: float):
	position = start_pos
	speed = ball_speed
	linear_velocity = Vector2(0, -speed)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.can_be_damaged():
			on_hit_player(body)

func on_hit_player(body):
	body.hit_by_anvil_ball(base_ball_damage)
