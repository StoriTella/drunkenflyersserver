extends RigidBody2D

class_name PolenBall

@export var speed: float = 50.0
@export var base_ball_damage = 5
@export var stick_duration: float = 1.5
@export var float_amplitude: float = 30.0
@export var float_frequency: float = 2.0
@export var direction_change_interval: float = 2.0

@export var expiration_date: float = 15.0

#GENERIC
@export var type_ball: BallTypeEnum.BallType = BallTypeEnum.BallType.POLEN
@export var ball_min_vel = 50.0
@export var ball_max_vel = 200.0
@export var ball_delay: float = 0.5

var start_pos: Vector2
var direction: Vector2
var time: float = 0.0
var float_offset: float = 0.0
var attached_to: Node2D = null

func _ready():
	await get_tree().create_timer(expiration_date).timeout
	if attached_to == null:
		queue_free()
	
	start_pos = position
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	var random_speed = randf_range(30, 80)
	speed = random_speed
	
	linear_velocity = direction * speed

func initialize(start_pos: Vector2, ball_speed: float):
	position = start_pos
	self.start_pos = start_pos
	speed = ball_speed
	
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	linear_velocity = direction * speed

func _physics_process(delta):
	if attached_to:
		global_position = attached_to.global_position
		return
	
	time += delta
	
	if time >= direction_change_interval:
		time = 0
		direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		linear_velocity = direction * speed
	
	float_offset = sin(Time.get_ticks_msec() * 0.003 * float_frequency) * float_amplitude
	position.x = start_pos.x + float_offset

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.can_be_damaged():
			on_hit_player(body)

func on_hit_player(body):
	attached_to = body
	linear_velocity = Vector2.ZERO
	gravity_scale = 0
	body.hit_by_polen_ball(base_ball_damage)
	await get_tree().create_timer(stick_duration).timeout
	queue_free()
