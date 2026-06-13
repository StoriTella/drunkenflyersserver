extends RigidBody2D

class_name BoomerangBall

@onready var sprite = $Sprite2D

@export var speed: float = 0.0
@export var damage: int = 10
@export var expiration_date: float = 40.0
@export var australia_duration: float = 2.0

#GENERIC
@export var type_ball: BallTypeEnum.BallType = BallTypeEnum.BallType.BOOMERANG
@export var ball_min_vel = 300
@export var ball_max_vel = 500
@export var ball_delay: float = 1.3

var total_distance: float = 0.0
var traveled: float = 0.0

var start_pos: Vector2
var end_pos: Vector2
var is_returning: bool = false
var target_pos: Vector2
var direction: Vector2 = Vector2.RIGHT

func _ready():
	await get_tree().create_timer(expiration_date).timeout
	queue_free()

func initialize(start_pos: Vector2, end_pos: Vector2, ball_speed: float):
	position = start_pos
	start_pos = start_pos
	speed = ball_speed
	total_distance = start_pos.distance_to(end_pos)
	
	var direction = (end_pos - start_pos).normalized()
	linear_velocity = direction * speed

func _physics_process(delta):
	#sprite.rotation = linear_velocity.angle()
	traveled += speed * delta
	sprite.rotation += 15.0 * delta
	
	if traveled >= total_distance:
		if not is_returning:
			is_returning = true
			traveled = 0.0
			target_pos = start_pos
			var direction = (target_pos - position).normalized()
			linear_velocity = direction * speed
		else:
			queue_free()

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		if body.can_be_damaged():
			body.hit_by_norma_ball(damage)
			queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.can_be_damaged():
			on_hit_player(body)

func on_hit_player(body):
	body.hit_by_boomerang_ball(damage, australia_duration)
	queue_free()
