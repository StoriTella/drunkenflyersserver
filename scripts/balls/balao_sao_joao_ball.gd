extends RigidBody2D

class_name BalaoSaoJoaoBall

@export var speed: float = 200.0
@export var base_ball_damage = 30
@export var swing_amplitude: float = 50.0
@export var swing_frequency: float = 5.0
var direction: Vector2 = Vector2.RIGHT
var start_x: float = 0.0
var time: float = 0.0

@export var ball_timer: float = 0.0

#GENERIC
@export var type_ball: BallTypeEnum.BallType = BallTypeEnum.BallType.BALAOSAOJOAO
@export var ball_min_vel = 200
@export var ball_max_vel = 800
@export var ball_delay: float = 0.5

@export var expiration_date: float = 30.0

var spawned_position: Vector2

func _ready():
	await get_tree().create_timer(expiration_date).timeout
	queue_free()

func initialize(start_pos: Vector2, ball_speed: float):
	position = start_pos
	start_x = start_pos.x
	speed = ball_speed
	linear_velocity = Vector2(0, -speed)

func _physics_process(delta):
	time += delta
	var offset = sin(time * swing_frequency) * swing_amplitude
	position.x = start_x + offset

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.can_be_damaged():
			on_hit_player(body)

func on_hit_player(body):
	body.hit_by_norma_ball(base_ball_damage)
	linear_velocity = Vector2.ZERO
	gravity_scale = 0.3
