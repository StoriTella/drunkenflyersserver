extends Node2D

enum CharacterType {
	WARRIOR,
	MAGE,
	ARCHER,
	PRIEST,
	DRUID,
	NANI,
	VIBE,
	INVENTOR,
	BARBARIAN,
	GUNSLINGUER,
	WARLOCK,
	BARD,
	ARTIFICER
}

@export var player_scene = preload("res://scenes/nave/nave.tscn")
@export var vibrate_time_end_game: int = 1000

var players = {}
var default_posiion = Vector2(0, 0)

func _ready():
	setup_server()
	setup_connection_players()

func setup_server():
	var port = 4242
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	print("Server Port: ", port)
	print("Server IP: ", get_local_ip())

func setup_connection_players():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)

func _on_player_connected(player_id):
	print("Player:  ", player_id, " connected")

	var new_player = player_scene.instantiate()
	new_player.name = str(player_id)
	new_player.set_multiplayer_authority(player_id)

	new_player.position = default_posiion
	new_player.player_id = player_id
	add_child(new_player)
	players[player_id] = new_player

	print("Player created on: ", new_player.position)

func _on_player_disconnected(player_id):
	print("Player ", player_id, " disconnected")
	if players.has(player_id):
		players[player_id].queue_free()
		players.erase(player_id)

@rpc("any_peer", "call_remote")
func ping():
	pass

@rpc("any_peer", "call_remote", "unreliable")
func update_gyro(gyro_data: Vector3):
	var player_id = multiplayer.get_remote_sender_id()
	if players.has(player_id):
		players[player_id].update_from_gyro(gyro_data)

@rpc("any_peer", "call_remote", "reliable")
func reset_orientation():
	var player_id = multiplayer.get_remote_sender_id()
	if players.has(player_id):
		players[player_id].reset_rotation()
		print("🔄 Reset recebido do jogador ", player_id)

func get_local_ip():
	var ip = IP.get_local_addresses()
	for address in ip:
		if address.begins_with("192.168.") or address.begins_with("10."):
			return address
	return ip[0] if ip.size() > 0 else "127.0.0.1"
	
@rpc("any_peer", "call_remote", "unreliable")
func update_gravity(gravity_data: Vector3):
	var player_id = multiplayer.get_remote_sender_id()
	if players.has(player_id):
		players[player_id].update_from_gravity(gravity_data)

@rpc("any_peer", "call_remote", "reliable")
func vibrate_player(player_id, duration_ms: int):
	rpc_id(player_id, "vibrate_player", duration_ms)

@rpc("any_peer", "call_remote", "reliable")
func normal_coin_sound(player_id):
	rpc_id(player_id, "normal_coin_sound")

@rpc("any_peer", "call_remote", "reliable")
func normal_damage_sound(player_id):
	rpc_id(player_id, "normal_damage_sound")

#SETTINGS

@rpc("any_peer", "call_remote", "reliable")
func set_player_name(player_name: String):
	var player_id = multiplayer.get_remote_sender_id()
	
	if players.has(player_id):
		players[player_id].name_label.text = player_name
		print("Player: ", player_id, " name: ", player_name)

@rpc("any_peer", "call_remote", "reliable")
func set_player_color(player_color: Color):
	var player_id = multiplayer.get_remote_sender_id()
	
	if players.has(player_id):
		players[player_id].modulate = player_color
		players[player_id].original_modulate = player_color
		players[player_id].current_modulate = player_color
		print("Player: ", player_id, " color: ", player_color)

@rpc("any_peer", "call_remote", "unreliable")
func set_player_character(character_type: int):
	var player_id = multiplayer.get_remote_sender_id()
	
	if players.has(player_id):
		players[player_id].set_character(character_type)
		print("Player: ", player_id, " chose character: ", CharacterType.keys()[character_type])

#POWER UPS

@rpc("any_peer", "call_remote", "reliable")
func add_speed_powerup():
	var player_id = multiplayer.get_remote_sender_id()
	
	if players.has(player_id):
		players[player_id].speed_powerup()
		print("Player: ", player_id, " speed power up")


@rpc("any_peer", "call_remote", "reliable")
func add_shield_powerup():
	var player_id = multiplayer.get_remote_sender_id()
	
	if players.has(player_id):
		players[player_id].shield_powerup()
		print("Player: ", player_id, " speed power up")
		
@rpc("any_peer", "call_remote", "reliable")
func perform_dash(direction: Vector2, force: float):
	var player_id = multiplayer.get_remote_sender_id()
	
	if players.has(player_id):
		players[player_id].apply_dash(direction, force)

@rpc("any_peer", "call_remote", "reliable")
func spike_powerup():
	var player_id = multiplayer.get_remote_sender_id()
	
	if players.has(player_id):
		var player_pos = players[player_id].global_position
		var spike_count = 8
		var radius = 100.0
		
		for i in range(spike_count):
			var angle = (2.0 * PI / spike_count) * i
			var direction = Vector2(cos(angle), sin(angle))
			var spawn_pos = player_pos + direction * radius
			
			spawn_spike(spawn_pos, direction)
		
		print("Player: ", player_id, " used spike powerup")

func spawn_spike(position: Vector2, direction: Vector2):
	var spike = preload("res://scenes/balls/spike.tscn").instantiate()
	spike.global_position = position
	spike.direction = direction
	spike.speed = 500.0
	add_child(spike)

@rpc("any_peer", "call_remote", "reliable")
func nuclear_missile_powerup():
	var player_id = multiplayer.get_remote_sender_id()
	
	for p in players:
		rpc_id(p, "set_core_enabled", false)
		players[p].set_core_enabled(false)
	
	print("Player: ", player_id, " nuked")

func vibrate_all_players(vibrate_time):
	rpc("vibrate_player", vibrate_time)

#system movement and core
func disable_player_direction(player_id: int, direction: String):
	match direction:
		"left":
			rpc_id(player_id, "set_left_enabled", false)
		"right":
			rpc_id(player_id, "set_right_enabled", false)
		"up":
			rpc_id(player_id, "set_up_enabled", false)
		"down":
			rpc_id(player_id, "set_down_enabled", false)
		"core":
			rpc_id(player_id, "set_core_enabled", false)

@rpc("any_peer", "call_remote", "reliable")
func update_systems_left():
	var player_id = multiplayer.get_remote_sender_id()
	
	for p in players:
		rpc_id(p, "set_left_enabled", false)
		players[p].set_left_enabled(false)
	
	print("Player: ", player_id, " disabled left for all")

@rpc("any_peer", "call_remote", "reliable")
func update_systems_right():
	var player_id = multiplayer.get_remote_sender_id()
	
	for p in players:
		rpc_id(p, "set_right_enabled", false)
		players[p].set_right_enabled(false)
	
	print("Player: ", player_id, " disabled right for all")

@rpc("any_peer", "call_remote", "reliable")
func update_systems_up():
	var player_id = multiplayer.get_remote_sender_id()
	
	for p in players:
		rpc_id(p, "set_up_enabled", false)
		players[p].set_up_enabled(false)
	
	print("Player: ", player_id, " disabled up for all")

@rpc("any_peer", "call_remote", "reliable")
func update_systems_down():
	var player_id = multiplayer.get_remote_sender_id()
	
	for p in players:
		rpc_id(p, "set_down_enabled", false)
		players[p].set_down_enabled(false)
	
	print("Player: ", player_id, " disabled down for all")

@rpc("any_peer", "call_remote", "reliable")
func update_systems_core():
	var player_id = multiplayer.get_remote_sender_id()
	
	for p in players:
		rpc_id(p, "set_core_enabled", false)
		players[p].set_core_enabled(false)
	
	print("Player: ", player_id, " disabled core for all")

@rpc("any_peer", "call_remote", "reliable")
func repair_systems_left():
	var player_id = multiplayer.get_remote_sender_id()
	
	if players.has(player_id):
		rpc_id(player_id, "set_left_enabled", true)
		players[player_id].set_left_enabled(true)

@rpc("any_peer", "call_remote", "reliable")
func repair_systems_right():
	var player_id = multiplayer.get_remote_sender_id()
	
	if players.has(player_id):
		rpc_id(player_id, "set_right_enabled", true)
		players[player_id].set_right_enabled(true)

@rpc("any_peer", "call_remote", "reliable")
func repair_systems_up():
	var player_id = multiplayer.get_remote_sender_id()
	
	if players.has(player_id):
		rpc_id(player_id, "set_up_enabled", true)
		players[player_id].set_up_enabled(true)

@rpc("any_peer", "call_remote", "reliable")
func repair_systems_down():
	var player_id = multiplayer.get_remote_sender_id()
	
	if players.has(player_id):
		rpc_id(player_id, "set_down_enabled", true)
		players[player_id].set_down_enabled(true)

@rpc("any_peer", "call_remote", "reliable")
func repair_systems_core():
	var player_id = multiplayer.get_remote_sender_id()
	
	if players.has(player_id):
		rpc_id(player_id, "set_core_enabled", true)
		players[player_id].set_core_enabled(true)

@rpc("any_peer", "call_remote", "reliable")
func set_left_enabled(enabled: bool):
	pass

@rpc("any_peer", "call_remote", "reliable")
func set_right_enabled(enabled: bool):
	pass

@rpc("any_peer", "call_remote", "reliable")
func set_up_enabled(enabled: bool):
	pass

@rpc("any_peer", "call_remote", "reliable")
func set_down_enabled(enabled: bool):
	pass

@rpc("any_peer", "call_remote", "reliable")
func set_core_enabled(enabled: bool):
	pass
