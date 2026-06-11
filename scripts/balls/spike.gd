extends RigidBody2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 500.0

func _ready():
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("players"):
		body.hit_by_spike()
		queue_free()
