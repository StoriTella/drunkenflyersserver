extends RigidBody2D

class_name CannonBall

var shooter_id: int = -1
var collision_enabled: bool = false
var damage: int = 100

func _ready():
	collision_layer = 3
	collision_mask = 0
	gravity_scale = 0
	await get_tree().create_timer(0.2).timeout
	enable_collision()

func enable_collision():
	collision_enabled = true
	collision_mask = 2

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not collision_enabled:
		return
	
	if body.is_in_group("player") and body.get_multiplayer_authority() != shooter_id:
		if !body.is_in_group("player_shield"):
			body.hit_by_cannonball(damage)
			queue_free()
