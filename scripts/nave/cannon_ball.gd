extends RigidBody2D

class_name CannonBall

var shooter_id: int = -1
var damage: int = 100

@onready var rigidbody_collision: CollisionShape2D = $CollisionShape2D
@onready var area2d_collision: CollisionShape2D = $CollisionShape2D
@export var timeout: float = 0.2
@export var expiration_date: float = 10.0

func _ready():
	area2d_collision.disabled = true
	rigidbody_collision.disabled = true
	await get_tree().create_timer(timeout).timeout
	enable_collision()
	await get_tree().create_timer(expiration_date).timeout
	queue_free()

func enable_collision():
	area2d_collision.disabled = false
	rigidbody_collision.disabled = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.get_multiplayer_authority() != shooter_id:
		if body.can_be_damaged():
			body.hit_by_cannonball(damage)
			queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
