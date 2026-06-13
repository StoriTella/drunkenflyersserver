extends RigidBody2D
class_name RubberBall

@export var speed: float = 50.0
@export var direction_change_interval: float = 3.0
@export var wall_duration: float = 3.0
@export var wall_size: Vector2 = Vector2(5, 5)
@export var point_radius: float = 3.0
@export var point_color: Color = Color.BLUE

#GENERIC
@export var type_ball: BallTypeEnum.BallType = BallTypeEnum.BallType.RUBBER
@export var ball_min_vel = 100
@export var ball_max_vel = 200
@export var ball_delay: float = 1.5
@export var expiration_date: float = 12.0

var direction: Vector2 = Vector2.RIGHT
var change_dir_timer: float = 0.0
var previous_position: Vector2
var has_previous: bool = false

func _ready():
	await get_tree().create_timer(expiration_date).timeout
	queue_free()

func initialize(start_pos: Vector2, ball_speed: float):
	position = start_pos
	speed = ball_speed
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	linear_velocity = direction * speed
	previous_position = start_pos
	has_previous = true
	call_deferred("create_point", global_position)

func _physics_process(delta):
	change_dir_timer += delta
	
	if change_dir_timer >= direction_change_interval:
		change_dir_timer = 0.0
		change_direction()

func change_direction():
	create_wall_segment(previous_position, global_position)
	previous_position = global_position
	create_point(global_position)
	
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	linear_velocity = direction * speed

func create_wall_segment(from: Vector2, to: Vector2):
	var wall = StaticBody2D.new()
	wall.collision_layer = 1
	wall.collision_mask = 2 | 3 | 4
	
	var length = from.distance_to(to)
	var angle = (to - from).angle()
	var center = (from + to) / 2
	
	var collision = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(length, wall_size.y)
	collision.shape = rect
	wall.add_child(collision)
	
	var sprite_wall = Sprite2D.new()
	var image = Image.create(max(1, int(length)), max(1, int(wall_size.y)), false, Image.FORMAT_RGBA8)
	image.fill(Color.RED)
	sprite_wall.texture = ImageTexture.create_from_image(image)
	wall.add_child(sprite_wall)
	
	wall.global_position = center
	wall.rotation = angle
	get_parent().add_child(wall)
	
	var timer = Timer.new()
	timer.wait_time = wall_duration
	timer.one_shot = true
	timer.timeout.connect(func(): if is_instance_valid(wall): wall.queue_free())
	wall.add_child(timer)
	timer.start()

func create_point(pos: Vector2):
	if not is_inside_tree():
		return
	
	var point = StaticBody2D.new()
	point.collision_layer = 0
	point.collision_mask = 0
	
	var collision = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = max(0.1, point_radius)
	collision.shape = circle
	point.add_child(collision)
	
	var sprite = Sprite2D.new()
	var size = max(2, int(point_radius * 2))
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(point_color)
	sprite.texture = ImageTexture.create_from_image(image)
	point.add_child(sprite)
	
	point.global_position = pos
	
	get_parent().add_child(point)
	
	var timer = Timer.new()
	timer.wait_time = wall_duration
	timer.one_shot = true
	timer.timeout.connect(func(): if is_instance_valid(point): point.queue_free())
	point.add_child(timer)
	timer.start()
