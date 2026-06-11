extends Node2D

@export var thickness = 20

func _ready():
	create_walls()

func create_walls():
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Paredes
	create_wall("Top", Vector2(0, -viewport_size.y / 2), Vector2(viewport_size.x, thickness))
	create_wall("Bottom", Vector2(0, viewport_size.y / 2), Vector2(viewport_size.x, thickness))
	create_wall("Left", Vector2(-viewport_size.x / 2, 0), Vector2(thickness, viewport_size.y))
	create_wall("Right", Vector2(viewport_size.x / 2, 0), Vector2(thickness, viewport_size.y))

func create_wall(name: String, pos: Vector2, size: Vector2):
	var wall = StaticBody2D.new()
	wall.name = name
	wall.position = pos
	
	var collision = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = size
	collision.shape = rect
	
	var sprite = Sprite2D.new()
	var image = Image.create(max(1, int(size.x)), max(1, int(size.y)), false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 0, 0))
	sprite.texture = ImageTexture.create_from_image(image)
	
	wall.add_child(collision)
	wall.add_child(sprite)
	add_child(wall)
