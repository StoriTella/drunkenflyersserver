extends RigidBody2D

class_name BaseCoin

@export var coin_type: PowerTypeEnum.PowerType
@export var points: int = 10
@export var speed: float = 0.0
@export var expiration_date: float = 10.0

var direction: Vector2 = Vector2.RIGHT
var spawned_position: Vector2
var target_position: Vector2

func _ready():
	match coin_type:
		PowerTypeEnum.PowerType.COIN:
			points = 10
	
	await get_tree().create_timer(expiration_date).timeout
	queue_free()

func initialize(start_pos: Vector2, end_pos: Vector2, coin_speed: float, coin_type_enum):
	position = start_pos
	spawned_position = start_pos
	target_position = end_pos
	speed = coin_speed
	coin_type = coin_type_enum
	
	
	#direction = (end_pos - start_pos).normalized()
	# linear_velocity = direction * speed

func on_collect(body):
	match coin_type:
		PowerTypeEnum.PowerType.COIN:
			body.collect_coin(points)
			queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		on_collect(body)
