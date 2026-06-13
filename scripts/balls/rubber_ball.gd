extends RigidBody2D
class_name RubberBall

@export var speed: float = 50.0
@export var direction_change_interval: float = 3.0
@export var wall_duration: float = 3.0
@export var wall_thickness: float = 5.0

#GENERIC
@export var type_ball: BallTypeEnum.BallType = BallTypeEnum.BallType.RUBBER
@export var ball_min_vel = 100
@export var ball_max_vel = 200
@export var ball_delay: float = 1.5
@export var expiration_date: float = 12.0

var direction: Vector2 = Vector2.RIGHT
var change_dir_timer: float = 0.0
var segment_start: Vector2
var current_wall: StaticBody2D = null

func _ready():
	await get_tree().create_timer(expiration_date).timeout
	queue_free()

func initialize(start_pos: Vector2, ball_speed: float):
	position = start_pos
	speed = ball_speed
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	linear_velocity = direction * speed
	segment_start = start_pos
	create_wall_segment()

func _physics_process(delta):
	change_dir_timer += delta
	if change_dir_timer >= direction_change_interval:
		change_dir_timer = 0.0
		change_direction()
	update_current_wall()

func change_direction():
	segment_start = global_position
	create_wall_segment()
	# Muda a direção
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	linear_velocity = direction * speed

func create_wall_segment():
	if current_wall:
		current_wall.queue_free()
	current_wall = StaticBody2D.new()
	current_wall.collision_layer = 1
	add_child(current_wall)
	
	var timer = Timer.new()
	timer.wait_time = wall_duration
	timer.one_shot = true
	timer.timeout.connect(func(): if is_instance_valid(current_wall): current_wall.queue_free())
	current_wall.add_child(timer)
	timer.start()
	
	update_current_wall()

func update_current_wall():
	if not current_wall:
		return
	var from = segment_start
	var to = global_position
	var length = from.distance_to(to)
	if length < 0.1:
		return
	var center = (from + to) / 2
	var angle = (to - from).angle()
	
	var collision = null
	if current_wall.get_child_count() > 0 and current_wall.get_child(0) is CollisionShape2D:
		collision = current_wall.get_child(0)
	else:
		collision = CollisionShape2D.new()
		current_wall.add_child(collision)
	
	var rect = RectangleShape2D.new()
	rect.size = Vector2(length, wall_thickness)
	collision.shape = rect
	
	var sprite = null
	if current_wall.get_child_count() > 1 and current_wall.get_child(1) is Sprite2D:
		sprite = current_wall.get_child(1)
	else:
		sprite = Sprite2D.new()
		current_wall.add_child(sprite)
	
	var image = Image.create(max(1, int(length)), max(1, int(wall_thickness)), false, Image.FORMAT_RGBA8)
	image.fill(Color.RED)
	sprite.texture = ImageTexture.create_from_image(image)
	
	current_wall.global_position = center
	current_wall.rotation = angle
