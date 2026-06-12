extends RigidBody2D

class_name Gold

@export var coin_type: PointsTypeEnum.PointsType = PointsTypeEnum.PointsType.COIN
@export var points: int = 1
@export var point_delay: float = 0.05

var direction: Vector2 = Vector2.RIGHT
var spawned_position: Vector2
var target_position: Vector2

func initialize(start_pos: Vector2, end_pos: Vector2):
	position = start_pos
	spawned_position = start_pos
	target_position = end_pos

func on_collect(body):
	body.collect_coin(points)
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		on_collect(body)


func _on_expiration_timer_timeout() -> void:
	queue_free()
