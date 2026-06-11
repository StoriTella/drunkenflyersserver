extends RigidBody2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 500.0
@export var expiration_date: float = 10.0

func _ready():
	await get_tree().create_timer(expiration_date).timeout
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.can_be_damaged():
			body.hit_by_spike(50)
			queue_free()
