extends Area2D

@onready var animated_player: AnimationPlayer = $AnimationPlayer

@export var explosion_damage: int = 20

func _ready():
	animated_player.play("explode")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.can_be_damaged():
			body.hit_by_explosion(explosion_damage)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
