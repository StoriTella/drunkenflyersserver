extends CharacterBody2D

@export var current_speed: float = 200.0
@export var default_speed: float = 200.0
@export var speed_boost: float = 300.0
@export var dents: int = 0
@export var max_dents: int = 5
@export var can_move: bool = true

@onready var cannonball_scene: PackedScene = preload("res://scenes/nave/cannon_ball.tscn")
@onready var banana_scene: PackedScene = preload("res://scenes/nave/banana_ball.tscn")
@onready var speed_timer: Timer = $SpeedTimer
@onready var shield_timer: Timer = $ShieldTimer
@onready var iman_timer: Timer = $ImanTimer
@onready var sprite = $Sprite2D
@onready var name_label = $NameLabel
@onready var core_damaged_animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var banana_powerup_place: Node2D = $Sprite2D/BananaPlace


var last_update_time: int = 0
var update_timeout_ms: int = 100

var left_enabled: bool = true
var right_enabled: bool = true
var up_enabled: bool = true
var down_enabled: bool = true
var core_enabled: bool = true

var initial_position: Vector2
var initial_rotation: float
var max_gyroscope: float = 10.0
var points = 0
var player_id

#Invert Controls
var invert_controls: bool = false
var invert_timer: Timer

#Speed power up
var speed_lines: Array = []
@export var speed_line_timer: float = 0.0
@export var speed_line_interval: float = 0.1
@export var speed_line_width: float = 4.0
@export var speed_line_length: float = 60.0
@export var speed_line_color: Color = Color(0.5, 0.8, 1.0, 0.8)
@export var speed_line_side_width: float = 3.0
@export var speed_line_side_length_factor: float = 0.7
@export var speed_line_side_color: Color = Color(0.5, 0.8, 1.0, 0.6)
@export var speed_line_offset_x: float = 15.0
@export var speed_line_offset_y: float = 10.0
@export var speed_line_duration: float = 0.15

#Shield Powerup
@export var shield_radius: float = 40.0
@export var shield_line_width: float = 3.0
@export var shield_color: Color = Color(0.5, 1.0, 0.5, 0.8)
@export var shield_segment_count: int = 36
@export var shield_pulse_speed: float = 5.0

var shield_circle: Line2D = null
var shield_pulse_time: float = 0.0

var input_dir: Vector2 = Vector2.ZERO

@export var line_width: float = 3.0
@export var duration: float = 1.0
@export var teleport_min_times: int = 5
@export var teleport_max_times: int = 10
@export var min_distance_teleport: int = 50
@export var max_distance_teleport: int = 200
@export var core_damaged_animated_sprite_rotation_speed: float = 2.5

@onready var iman: Sprite2D = $Iman
@onready var iman_area: Area2D = $Iman/Area2D

#iman power up
var iman_players_theft = []
@export var iman_steal_rate: float = 0.1
@export var iman_line_width: float = 2.0
var active_lines: Dictionary = {} 
var coin_sprites: Dictionary = {}
var coin_progress: Dictionary = {}
@export var coin_speed: float = 1.5
@export var coin_scale: float = 0.3
@onready var coin_frames: SpriteFrames = preload("res://assets/points/gold/gold_sprite_frames.tres")
@export var coin_count: int = 5
@export var coin_spacing: float = 0.15

func _ready():
	iman.visible = false
	initial_position = position
	initial_rotation = rotation
	name_label.text = "John Doe"
	invert_timer = Timer.new()
	invert_timer.one_shot = true
	invert_timer.timeout.connect(_on_invert_timeout)
	add_child(invert_timer)
	last_update_time = Time.get_ticks_msec()

func _physics_process(delta):
	process_iman_powerup()
	iman_power_up_update_lines(delta)
	var now = Time.get_ticks_msec()
	if now - last_update_time > update_timeout_ms:
		input_dir = Vector2.ZERO
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	velocity = input_dir * current_speed
	sprite.rotation = velocity.angle()
	
	if current_speed > default_speed:
		speed_line_timer += get_process_delta_time()
		if speed_line_timer >= speed_line_interval:
			speed_line_timer = 0.0
			create_speed_line()
	
	move_and_slide()

func _process(delta):
	if shield_circle:
		shield_pulse_time += delta * shield_pulse_speed
		var pulse_scale = 1.0 + sin(shield_pulse_time) * 0.1
		var current_radius = shield_radius * pulse_scale
		
		shield_circle.clear_points()
		for i in range(shield_segment_count + 1):
			var angle = (2.0 * PI / shield_segment_count) * i
			var x = cos(angle) * current_radius
			var y = sin(angle) * current_radius
			shield_circle.add_point(Vector2(x, y))
	if !core_enabled:
		rotation += core_damaged_animated_sprite_rotation_speed * delta
		#core_damaged_animated_sprite.rotation -= core_damaged_animated_sprite_rotation_speed * delta
	else:
		#core_damaged_animated_sprite.rotation = 0
		rotation = 0
	
	for target in iman_players_theft:
		if active_lines.has(target.player_id) and coin_sprites.has(target.player_id):
			var sprites = coin_sprites[target.player_id]
			var progresses = coin_progress[target.player_id]
			var line = active_lines[target.player_id]
			if line.get_point_count() < 2:
				continue
			var start = line.get_point_position(1)
			var end = line.get_point_position(0)
			for i in range(sprites.size()):
				progresses[i] += delta * coin_speed
				if progresses[i] > 1.0:
					progresses[i] = 0.0
				var pos = start.lerp(end, progresses[i])
				sprites[i].position = pos

func update_from_gravity(gravity: Vector3):
	if !can_move && !core_enabled:
		return
	
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
	
	self.input_dir = input_dir
	last_update_time = Time.get_ticks_msec() 


func create_speed_line():
	var line = Line2D.new()
	line.width = speed_line_width
	line.default_color = speed_line_color
	
	var backward = -velocity.normalized() * speed_line_length
	
	var center_pos = Vector2.ZERO
	var left_pos = Vector2(-speed_line_offset_x, -speed_line_offset_y) + backward
	var right_pos = Vector2(speed_line_offset_x, -speed_line_offset_y) + backward
	
	line.add_point(center_pos)
	line.add_point(center_pos + backward)
	
	add_child(line)
	speed_lines.append(line)
	
	var line_left = Line2D.new()
	line_left.width = speed_line_side_width
	line_left.default_color = speed_line_side_color
	line_left.add_point(left_pos)
	line_left.add_point(left_pos + backward * speed_line_side_length_factor)
	add_child(line_left)
	speed_lines.append(line_left)
	
	var line_right = Line2D.new()
	line_right.width = speed_line_side_width
	line_right.default_color = speed_line_side_color
	line_right.add_point(right_pos)
	line_right.add_point(right_pos + backward * speed_line_side_length_factor)
	add_child(line_right)
	speed_lines.append(line_right)
	
	await get_tree().create_timer(speed_line_duration).timeout
	for l in [line, line_left, line_right]:
		l.queue_free()
		speed_lines.erase(l)

func create_shield_circle():
	if shield_circle:
		remove_shield_circle()
	
	shield_circle = Line2D.new()
	shield_circle.width = shield_line_width
	shield_circle.default_color = shield_color
	add_child(shield_circle)
	
	update_shield_circle()

func update_shield_circle():
	if not shield_circle:
		return
	
	shield_circle.clear_points()
	
	for i in range(shield_segment_count + 1):
		var angle = (2.0 * PI / shield_segment_count) * i
		var x = cos(angle) * shield_radius
		var y = sin(angle) * shield_radius
		shield_circle.add_point(Vector2(x, y))

func remove_shield_circle():
	if shield_circle:
		shield_circle.queue_free()
		shield_circle = null

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
	
func collect_coin(coin_points, make_sound: bool):
	points += coin_points
	if make_sound:
		Global.normal_coin_sound(player_id)

#HIT

func hit_by_base_ball(damage):
	points -= damage
	dents += 1
	Global.rpc_id(player_id, "hit_by_base_ball_sound")
	check_ship_failure()

func hit_by_anvil_ball(damage: int):
	points += damage
	Global.rpc_id(player_id, "hit_by_anvil_ball_sound")
	set_core_enabled(false)
	core_damaged_animated_sprite.visible = true
	Global.disable_player_direction(player_id, "core")

func hit_by_balao_sao_joao_ball(damage):
	points -= damage
	dents += 1
	Global.rpc_id(player_id, "hit_by_balao_sao_joao_ball_sound")
	check_ship_failure()

func hit_by_boomerang_ball(damage, stun_duration):
	points -= damage
	dents += 0
	Global.rpc_id(player_id, "hit_by_boomerang_ball_sound")
	check_ship_failure()
	set_invert_controls(stun_duration)

func hit_by_explosion(damage):
	points -= damage
	dents += 3
	Global.rpc_id(player_id, "hit_by_explosion_sound")
	check_ship_failure()

func hit_by_polen_ball(damage):
	points -= damage
	dents += 0
	Global.rpc_id(player_id, "hit_by_polen_ball_sound")
	check_ship_failure()

func hit_by_tumbleweed_ball(damage, margin_teleport):
	points -= damage
	dents += 0
	Global.rpc_id(player_id, "hit_by_tumbleweed_ball_sound")
	check_ship_failure()
	var n_teleports = randi_range(teleport_min_times, teleport_max_times)
	for i in range(n_teleports):
		portal_teleport()
	#random_teleport(margin_teleport)

func hit_by_cannonball(damage: int):
	points -= damage
	Global.rpc_id(player_id, "hit_by_spike_sound")
	set_core_enabled(false)
	core_damaged_animated_sprite.visible = true
	Global.disable_player_direction(player_id, "core")

func hit_by_banana_ball(damage: int):
	points -= damage
	Global.rpc_id(player_id, "hit_by_banana_sound")
	set_core_enabled(false)
	core_damaged_animated_sprite.visible = true
	Global.disable_player_direction(player_id, "core")

func portal_teleport():
	var start = position
	var distance_teleport = randi_range(min_distance_teleport, max_distance_teleport)
	var end = GenericPositions.get_random_position_near(start,distance_teleport , 50.0)
	
	var line = Line2D.new()
	line.width = line_width
	line.default_color = modulate
	line.add_point(start)
	line.add_point(end)
	get_parent().add_child(line)
	position = end

	if duration > 0:
		await get_tree().create_timer(duration).timeout
		if is_instance_valid(line):
			line.queue_free()

func random_teleport(margin: float = 100.0):
	var viewport = get_viewport().get_visible_rect().size
	var min_x = -viewport.x / 2 + margin
	var max_x = viewport.x / 2 - margin
	var min_y = -viewport.y / 2 + margin
	var max_y = viewport.y / 2 - margin
	
	var attempts = 0
	var max_attempts = 10
	
	while attempts < max_attempts:
		var random_x = position.x + randf_range(-margin, margin)
		var random_y = position.y + randf_range(-margin, margin)
		
		if random_x >= min_x and random_x <= max_x and random_y >= min_y and random_y <= max_y:
			position = Vector2(random_x, random_y)
			return
		
		attempts += 1
	
	var safe_x = clamp(position.x, min_x, max_x)
	var safe_y = clamp(position.y, min_y, max_y)
	position = Vector2(safe_x, safe_y)

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

func vibrate_player(player_id: int, vibrate_time):
	Global.vibrate_player(player_id, vibrate_time)

func update_name(new_name: String):
	if name_label:
		name_label.text = new_name

#POWER UPS
func speed_powerup():
	if !speed_timer.is_stopped():
		speed_timer.stop()
	speed_timer.start()
	current_speed = speed_boost

func _on_speed_timer_timeout() -> void:
	current_speed = default_speed

func shield_powerup():
	if !shield_timer.is_stopped():
		shield_timer.stop()
	shield_timer.start()
	add_to_group("player_shield")
	create_shield_circle()

func _on_shield_timer_timeout() -> void:
	remove_from_group("player_shield")
	remove_shield_circle()

func cannonball_powerup(direction: Vector2, force: float):
	var cannonball = cannonball_scene.instantiate()
	cannonball.global_position = global_position
	cannonball.linear_velocity = direction * (force/10)
	cannonball.shooter_id = player_id
	get_parent().add_child(cannonball)

func add_banana_powerup():
	var banana_ball = banana_scene.instantiate()
	banana_ball.global_position = banana_powerup_place.global_position
	banana_ball.shooter_id = player_id
	banana_ball.modulate = modulate
	get_parent().add_child(banana_ball)

func add_iman_powerup():
	if !iman_timer.is_stopped():
		iman_timer.stop()
	iman_timer.start()
	iman.visible = true

func process_iman_powerup():
	var iman_active = iman.visible
	if iman_active:
		for player in iman_players_theft:
			var has_player_active_line = active_lines.has(player.player_id)
			if !has_player_active_line:
				if player.can_be_damaged():
					iman_power_up_add_line(player)
			elif !player.can_be_damaged():
					Global.rpc_id(player.player_id, "remove_hit_by_iman_sound")
					iman_power_up_remove_line(player.player_id)
	else:
		for player in iman_players_theft:
			if active_lines.has(player.player_id):
				Global.rpc_id(player.player_id, "remove_hit_by_iman_sound")
				iman_power_up_remove_line(player.player_id)

func _on_iman_timer_timeout() -> void:
	iman.visible = false

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
	core_damaged_animated_sprite.visible = false
	core_enabled = enabled

func set_invert_controls(duration: float):
	invert_controls = true
	invert_timer.start(duration)

func _on_invert_timeout():
	invert_controls = false

#Settings

func set_character(character_type: int):
	return
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

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#TODO add sound
	position = GenericPositions.get_random_position_in_screen()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.player_id != player_id:
			iman_players_theft.append(Global.players.get(body.player_id))

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.player_id != player_id and iman_players_theft.has(Global.players.get(body.player_id)):
			iman_players_theft.erase(Global.players.get(body.player_id))
			Global.rpc_id(body.player_id, "remove_hit_by_iman_sound")
			iman_power_up_remove_line(body.player_id)

func iman_power_up_add_line(target: Node2D):
	Global.rpc_id(target.player_id, "hit_by_iman_sound")
	var line = Line2D.new()
	line.width = line_width
	line.default_color = modulate
	line.antialiased = true
	add_child(line)
	active_lines[target.player_id] = line
	
	var sprites = []
	var progresses = []
	for i in range(coin_count):
		var sprite = AnimatedSprite2D.new()
		sprite.sprite_frames = coin_frames
		sprite.play("default")
		sprite.scale = Vector2(coin_scale, coin_scale)
		sprite.z_index = 10
		add_child(sprite)
		sprites.append(sprite)
		progresses.append(float(i) / coin_count)
	coin_sprites[target.player_id] = sprites
	coin_progress[target.player_id] = progresses

func iman_power_up_remove_line(target_id: int):
	if active_lines.has(target_id):
		active_lines[target_id].queue_free()
		active_lines.erase(target_id)
		
	if coin_sprites.has(target_id):
		for sprite in coin_sprites[target_id]:
			sprite.queue_free()
		coin_sprites.erase(target_id)
		coin_progress.erase(target_id)

func iman_power_up_update_lines(delta):
	for target in iman_players_theft:
		if active_lines.has(target.player_id):
			var line = active_lines[target.player_id]
			line.clear_points()
			line.add_point(Vector2.ZERO)
			line.add_point(to_local(target.global_position))
			Global.players.get(player_id).points += iman_steal_rate
			Global.players.get(target.player_id).points -= iman_steal_rate
			print("nave que está a roubar:", Global.players.get(player_id).points)
			print("nave que está a ser roubada:", Global.players.get(target.player_id).points)
