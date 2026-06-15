extends RigidBody2D

class_name BombBall

@export var speed: float = 200.0

@export var ball_timer: float = 0.0

#GENERIC
@export var type_ball: BallTypeEnum.BallType = BallTypeEnum.BallType.BOMB
@export var ball_min_vel = 200
@export var ball_max_vel = 400
@export var ball_delay: float = 0.5

@export var ball_damage = 15
@export var explosion_scene: PackedScene = preload("res://scenes/balls/special/explosion.tscn")

@export var expiration_date: float = 15.0
@export var expiration_date_off_screen: float = 0.5

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

func on_hit_player(body):
	explode()

func explode():
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_parent().add_child(explosion)
	call_deferred("queue_free")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == self:
		return
	if body.is_in_group("player"):
		if body.can_be_damaged():
			on_hit_player(body)
	if body.is_in_group("bomb_ball"):
		explode()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	await get_tree().create_timer(expiration_date_off_screen).timeout
	queue_free()
