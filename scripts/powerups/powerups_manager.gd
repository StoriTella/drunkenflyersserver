extends Node

@export var coin_scene: PackedScene = preload("res://scenes/powerups/base_powerup.tscn")
@export var margin = 50

var game_server: Node2D
var screen_size: Vector2
var power_up_speed: float = 0.0
var spawning: bool = false

# Timers
var coin_timer: float = 0.0
var coin_delay: float = 0.2

func _ready():
	await get_tree().process_frame
	game_server = get_parent()
	screen_size = get_viewport().get_visible_rect().size
	print("coin_scene: ", coin_scene)

func _process(delta):
	if not spawning:
		return
	coin_timer += delta
	if coin_timer >= coin_delay:
		coin_timer = 0.0
		spawn_coin()

func start_spawning():
	spawning = true

func stop_spawning():
	spawning = false

func spawn_coin():
	if coin_scene == null:
		print("❌ Coin scene não atribuída!")
		return
	
	var obj = coin_scene.instantiate()
	var spawn_pos = GenericPositions.get_random_position_in_screen(margin) 
	obj.position = spawn_pos
	
	if obj.has_method("initialize"):
		obj.initialize(spawn_pos, spawn_pos, 0, PowerTypeEnum.PowerType.COIN) 
	
	add_child(obj)
	
func remove_object(obj):
	if obj and is_instance_valid(obj):
		obj.queue_free()
