extends RigidBody2D

class_name BaseBall

@export var ball_min_vel = 500
@export var ball_max_vel = 800
@export var speed: float = 200.0
@export var base_ball_damage = 5

@export var ball_timer: float = 0.0
@export var ball_delay: float = 0.2

@export var type_ball: BallTypeEnum.BallType = BallTypeEnum.BallType.NORMAL
@export var expiration_date: float = 30.0

var direction: Vector2 = Vector2.RIGHT
var spawned_position: Vector2
var target_position: Vector2

func _ready():
	await get_tree().create_timer(expiration_date).timeout
	queue_free()

func initialize(start_pos: Vector2, end_pos: Vector2, ball_speed: float):
	position = start_pos
	spawned_position = start_pos
	target_position = end_pos
	speed = ball_speed
	
	direction = (end_pos - start_pos).normalized()
	linear_velocity = direction * speed

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.can_be_damaged():
			on_hit_player(body)

func on_hit_player(body):
	body.hit_by_norma_ball(base_ball_damage)
	queue_free()
