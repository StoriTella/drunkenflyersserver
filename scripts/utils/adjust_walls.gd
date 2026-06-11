extends Area2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

func _ready():
	await get_tree().process_frame
	adjust_sprite_to_collision()

func adjust_sprite_to_collision():
	var rect_size = collision.shape.size
	
	if sprite and sprite.texture:
		var tex_size = sprite.texture.get_size()
		sprite.scale = Vector2(rect_size.x / tex_size.x, rect_size.y / tex_size.y)
		sprite.position = rect_size / 2
