extends RigidBody2D

class_name Diamond


@export var points: int = 50
@export var speed: float = 400.0
@export var lifetime: float = 5.0
var start_pos: Vector2
var direction: Vector2

@export var launch_interval: float = 5.0
@export var launch_speed: float = 500.0
@export var launch_angle_min: float = 0.0
@export var launch_angle_max: float = 360.0
var timer: float = 0.0

@export var expiration_date: float = 30.0
@export var expiration_date_off_screen: float = 0.1

#GENERIC
@export var coin_type: PointsTypeEnum.PointsType = PointsTypeEnum.PointsType.DIAMOND
@export var point_delay: float = 1.0

@export var make_sound: bool = true

func _ready():
	await get_tree().create_timer(expiration_date).timeout
	queue_free()

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
		on_collect(body)

func on_collect(body):
	body.collect_coin(points, make_sound)
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	await get_tree().create_timer(expiration_date_off_screen).timeout
	queue_free()
