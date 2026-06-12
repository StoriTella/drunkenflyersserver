extends CharacterBody2D

@export var current_speed: float = 500 
@export var default_speed: float = 500.0
@export var speed_boost: float = 800.0
@export var speed_color: Color = Color(0.5, 0.8, 1.0)
@export var shield_color: Color =Color(0.5, 1.0, 0.5)
@export var damage_color: Color = Color.RED
@export var coin_color: Color = Color.GOLD
@export var dents: int = 0
@export var max_dents: int = 2

@onready var speed_timer: Timer = $SpeedTimer
@onready var shield_timer: Timer = $ShieldTimer
@onready var sprite = $Sprite2D
@onready var name_label = $NameLabel

var left_enabled: bool = true
var right_enabled: bool = true
var up_enabled: bool = true
var down_enabled: bool = true
var core_enabled: bool = true

var initial_position: Vector2
var initial_rotation: float
var max_gyroscope: float = 10.0
var points = 0
var original_modulate: Color
var current_modulate: Color
var vibrate_time: int  = 100
var vibrate_time_explosion: int = 1000
var vibrate_time_hard: int  = 500
var player_id

#Invert Controls
var invert_controls: bool = false
var invert_timer: Timer

func _ready():
	initial_position = position
	initial_rotation = rotation
	name_label.text = "John Doe"
	original_modulate = modulate
	current_modulate = original_modulate
	invert_timer = Timer.new()
	invert_timer.one_shot = true
	invert_timer.timeout.connect(_on_invert_timeout)
	add_child(invert_timer)

func update_from_gravity(gravity: Vector3):
	var horizontal = gravity.x
	var vertical = -gravity.y

	horizontal = clamp(horizontal / 5.0, -1.0, 1.0)
	vertical = clamp(vertical / 5.0, -1.0, 1.0)

	if abs(horizontal) < 0.1:
		horizontal = 0.0
	if abs(vertical) < 0.1:
		vertical = 0.0
	
	if invert_controls:
		horizontal = -horizontal
		vertical = -vertical
	
	if abs(horizontal) < 0.1:
		horizontal = 0.0
	if abs(vertical) < 0.1:
		vertical = 0.0
	
	var raw_horizontal = horizontal
	var raw_vertical = vertical
	
	if not left_enabled and raw_horizontal < 0:
		horizontal = 0.0
	if not right_enabled and raw_horizontal > 0:
		horizontal = 0.0
	if not up_enabled and raw_vertical < 0:
		vertical = 0.0
	if not down_enabled and raw_vertical > 0:
		vertical = 0.0
	
	if not core_enabled:
		horizontal = 0.0
		vertical = 0.0
	
	var input_dir = Vector2(horizontal, vertical)
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
	
	velocity = input_dir * current_speed
	move_and_slide()

func reset_rotation():
	position = initial_position
	rotation = initial_rotation
	velocity = Vector2.ZERO
	print("Reset")

func can_be_damaged():
	if is_in_group("player_shield"):
		return false
	return true

func update_from_gyro(gyro: Vector3):
	pass
	
func collect_coin(points):
	points += points
	flash_golden_border()
	show_points_received(points)
	Global.normal_coin_sound(player_id)

func hit_by_spike(damage: int):
	points += damage
	flash_red()
	show_damage_received(damage)
	Global.normal_damage_sound(player_id)
	vibrate_player(player_id, vibrate_time_hard)
	set_core_enabled(false)
	Global.disable_player_direction(player_id, "core")

func hit_by_norma_ball(damage):
	points -= damage
	dents += 1
	flash_red()
	show_damage_received(damage)
	Global.normal_damage_sound(player_id)
	vibrate_player(player_id, vibrate_time)
	check_ship_failure()

func hit_by_boomerang_ball(damage, stun_duration):
	points -= damage
	dents += 0
	flash_red()
	show_damage_received(damage)
	Global.normal_damage_sound(player_id)
	vibrate_player(player_id, vibrate_time_hard)
	check_ship_failure()
	#TODO ADICIONAR SUPER SOM AO PLAYER AUSTRALIANO
	set_invert_controls(stun_duration)

func hit_by_explosion(damage):
	points -= damage
	dents += 3
	flash_red()
	show_damage_received(damage)
	Global.normal_damage_sound(player_id)
	vibrate_player(player_id, vibrate_time_explosion)
	check_ship_failure()

func check_ship_failure():
	if dents >= max_dents:
		var random_dir = randi_range(0, 3)
		match random_dir:
			0:
				set_left_enabled(false)
				Global.disable_player_direction(player_id, "left")
			1:
				set_right_enabled(false)
				Global.disable_player_direction(player_id, "right")
			2:
				set_up_enabled(false)
				Global.disable_player_direction(player_id, "up")
			3:
				set_down_enabled(false)
				Global.disable_player_direction(player_id, "down")
		
		dents = 0

func flash_golden_border():
	modulate = coin_color
	await get_tree().create_timer(0.2).timeout
	modulate = current_modulate

# Método para mostrar pontos recebidos
func show_points_received(amount: int):
	# Cria uma label temporária
	var points_label = Label.new()
	points_label.text = "+" + str(amount)
	points_label.position = Vector2(-20, -50)
	points_label.add_theme_font_size_override("font_size", 20)
	points_label.modulate = coin_color
	add_child(points_label)
	
	var tween = create_tween()
	tween.tween_property(points_label, "position", Vector2(-20, -80), 0.5)
	tween.parallel().tween_property(points_label, "modulate", Color.TRANSPARENT, 0.5)
	tween.tween_callback(points_label.queue_free)

func flash_red():
	modulate = damage_color
	await get_tree().create_timer(0.2).timeout
	modulate = current_modulate

func show_damage_received(amount: int):
	var damage_label = Label.new()
	damage_label.text = "-" + str(amount)
	damage_label.position = Vector2(-20, -50)
	damage_label.add_theme_font_size_override("font_size", 20)
	damage_label.modulate = damage_color
	add_child(damage_label)
	
	var tween = create_tween()
	tween.tween_property(damage_label, "position", Vector2(-20, -80), 0.5)
	tween.parallel().tween_property(damage_label, "modulate", Color.TRANSPARENT, 0.5)
	tween.tween_callback(damage_label.queue_free)

func vibrate_player(player_id: int, vibrate_time):
	Global.vibrate_player(player_id, vibrate_time)

#POWER UPS

func update_name(new_name: String):
	if name_label:
		name_label.text = new_name

func speed_powerup():
	if !speed_timer.is_stopped():
		speed_timer.stop()
	speed_timer.start()
	current_speed = speed_boost
	modulate = speed_color
	current_modulate = speed_color

func _on_speed_timer_timeout() -> void:
	Global.vibrate_player(player_id, vibrate_time_hard)
	current_speed = default_speed
	modulate = original_modulate
	current_modulate = original_modulate

func shield_powerup():
	if !shield_timer.is_stopped():
		shield_timer.stop()
	shield_timer.start()
	add_to_group("player_shield")
	modulate = shield_color
	current_modulate = shield_color

func _on_shield_timer_timeout() -> void:
	Global.vibrate_player(player_id, vibrate_time_hard)
	remove_from_group("player_shield")
	modulate = original_modulate
	current_modulate = original_modulate

func apply_dash(direction: Vector2, force: float):
	velocity = direction * force
	move_and_slide()
	await get_tree().create_timer(0.2).timeout
	velocity = Vector2.ZERO

#MOVEMENT AND CORE

func set_left_enabled(enabled: bool):
	left_enabled = enabled

func set_right_enabled(enabled: bool):
	right_enabled = enabled

func set_up_enabled(enabled: bool):
	up_enabled = enabled

func set_down_enabled(enabled: bool):
	down_enabled = enabled

func set_core_enabled(enabled: bool):
	core_enabled = enabled

func set_invert_controls(duration: float):
	invert_controls = true
	invert_timer.start(duration)

func _on_invert_timeout():
	invert_controls = false

#Settings

func set_character(character_type: int):
	
	match character_type:
		Global.CharacterType.WARRIOR:
			sprite.texture = preload("res://assets/player_characters/warrior.jpeg")
		Global.CharacterType.MAGE:
			sprite.texture = preload("res://assets/player_characters/mage.png")
		Global.CharacterType.ARCHER:
			sprite.texture = preload("res://assets/player_characters/archer.jpeg")
		Global.CharacterType.PRIEST:
			sprite.texture = preload("res://assets/player_characters/priest.jpg")
		Global.CharacterType.DRUID:
			sprite.texture = preload("res://assets/player_characters/druid.png")
		Global.CharacterType.NANI:
			sprite.texture = preload("res://assets/player_characters/nani.png")
		Global.CharacterType.VIBE:
			sprite.texture = preload("res://assets/player_characters/vibe.png")
		Global.CharacterType.INVENTOR:
			sprite.texture = preload("res://assets/player_characters/inventor.png")
		Global.CharacterType.BARBARIAN:
			sprite.texture = preload("res://assets/player_characters/barbarian.png")
		Global.CharacterType.GUNSLINGUER:
			sprite.texture = preload("res://assets/player_characters/gunslinguer.png")
		Global.CharacterType.WARLOCK:
			sprite.texture = preload("res://assets/player_characters/warlock.png")
		Global.CharacterType.BARD:
			sprite.texture = preload("res://assets/player_characters/bard.jpeg")
		Global.CharacterType.ARTIFICER:
			sprite.texture = preload("res://assets/player_characters/artificer.png")
	
	var target_size = Vector2(64, 64)
	var texture_size = sprite.texture.get_size()
	var scale_x = target_size.x / texture_size.x
	var scale_y = target_size.y / texture_size.y
	
	sprite.scale = Vector2(scale_x, scale_y)
