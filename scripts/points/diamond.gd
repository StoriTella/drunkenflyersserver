extends RigidBody2D

class_name Diamond


@export var points: int = 50
@export var speed: float = 400.0
@export var lifetime: float = 5.0
var start_pos: Vector2
var direction: Vector2

@export var launch_interval: float = 2.0
@export var launch_speed: float = 500.0
@export var launch_angle_min: float = 0.0
@export var launch_angle_max: float = 360.0
var timer: float = 0.0

#GENERIC
@export var coin_type: PointsTypeEnum.PointsType = PointsTypeEnum.PointsType.DIAMOND
@export var point_delay: float = 1.0
@export var expiration_date: float = 20.0

func initialize(start_pos: Vector2):
	position = start_pos
	launch()

func launch():
	
	var angle = deg_to_rad(randf_range(launch_angle_min, launch_angle_max))
	var velocity = Vector2(cos(angle), sin(angle)) * launch_speed
	
	linear_velocity = velocity

func _process(delta):
	timer += delta
	if timer >= launch_interval:
		timer = 0.0
		launch()

func _on_expiration_timer_timeout() -> void:
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.collect_coin(points)
		queue_free()
