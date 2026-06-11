extends RigidBody2D

class_name BaseBall

@export var speed: float = 200.0
@export var type_ball: BallTypeEnum.BallType = BallTypeEnum.BallType.NORMAL
@export var expiration_date: float = 10.0
@export var normal_ball_damage = 5
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
	match type_ball:
		BallTypeEnum.BallType.NORMAL:
			body.hit_by_norma_ball(normal_ball_damage)
	queue_free()
