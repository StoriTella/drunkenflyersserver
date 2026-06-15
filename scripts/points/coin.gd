extends RigidBody2D

class_name Coin

@export var coin_type: PointsTypeEnum.PointsType = PointsTypeEnum.PointsType.COIN
@export var points: int = 10
@export var point_delay: float = 0.5
@export var expiration_date_off_screen: float = 0.1
@export var expiration_date: float = 15.0
@export var make_sound: bool = true

var direction: Vector2 = Vector2.RIGHT

func _ready():
	await get_tree().create_timer(expiration_date).timeout
	queue_free()

func initialize(start_pos: Vector2):
	position = start_pos

func on_collect(body):
	body.collect_coin(points, make_sound)
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		on_collect(body)


func _on_expiration_timer_timeout() -> void:
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	await get_tree().create_timer(expiration_date_off_screen).timeout
	queue_free()
