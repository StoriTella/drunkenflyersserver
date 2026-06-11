extends CharacterBody2D

@export var max_speed: float = 800.0
@onready var sprite = $Sprite2D
@onready var name_label = $NameLabel
var initial_position: Vector2
var initial_rotation: float
var max_gyroscope: float = 10.0
var points = 0
var original_modulate: Color
var vibrate_time: int  = 100
var player_id

func _ready():
	initial_position = position
	initial_rotation = rotation
	name_label.text = "Vinte"#name
	original_modulate = modulate

func update_from_gravity(gravity: Vector3):
	var horizontal = gravity.x   # LEFT-/RIGHT+
	var vertical = gravity.z     # FORWARD-/BACK+
	
	horizontal = clamp(horizontal / max_gyroscope, -1.0, 1.0)
	vertical = clamp(vertical / max_gyroscope, -1.0, 1.0)
	
	#DEADZONE
	if abs(horizontal) < 0.1:
		horizontal = 0.0
	if abs(vertical) < 0.1:
		vertical = 0.0
	
	var input_dir = Vector2(horizontal, vertical)
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
	
	velocity = input_dir * max_speed
	move_and_slide()

func reset_rotation():
	position = initial_position
	rotation = initial_rotation
	velocity = Vector2.ZERO
	print("Reset")

func update_from_gyro(gyro: Vector3):
	pass
	
func collect_coin(points):
	points += points
	flash_golden_border()
	show_points_received(points)
	Global.normal_coin_sound(player_id)

func hit_by_norma_ball(damage: int = 10):
	points -= damage
	flash_red()
	show_damage_received(damage)
	Global.normal_damage_sound(player_id)
	vibrate_player(player_id, vibrate_time)

func flash_golden_border():
	modulate = Color.GOLD
	await get_tree().create_timer(0.2).timeout
	modulate = original_modulate

# Método para mostrar pontos recebidos
func show_points_received(amount: int):
	# Cria uma label temporária
	var points_label = Label.new()
	points_label.text = "+" + str(amount)
	points_label.position = Vector2(-20, -50)
	points_label.add_theme_font_size_override("font_size", 20)
	points_label.modulate = Color.GOLD
	add_child(points_label)
	
	var tween = create_tween()
	tween.tween_property(points_label, "position", Vector2(-20, -80), 0.5)
	tween.parallel().tween_property(points_label, "modulate", Color.TRANSPARENT, 0.5)
	tween.tween_callback(points_label.queue_free)

func flash_red():
	modulate = Color.RED
	await get_tree().create_timer(0.2).timeout
	modulate = original_modulate

func show_damage_received(amount: int):
	var damage_label = Label.new()
	damage_label.text = "-" + str(amount)
	damage_label.position = Vector2(-20, -50)
	damage_label.add_theme_font_size_override("font_size", 20)
	damage_label.modulate = Color.RED
	add_child(damage_label)
	
	var tween = create_tween()
	tween.tween_property(damage_label, "position", Vector2(-20, -80), 0.5)
	tween.parallel().tween_property(damage_label, "modulate", Color.TRANSPARENT, 0.5)
	tween.tween_callback(damage_label.queue_free)

# Para vibrar um jogador específico
func vibrate_player(player_id: int, vibrate_time):
	Global.vibrate_player(player_id, vibrate_time)

func update_name(new_name: String):
	if name_label:
		name_label.text = new_name
