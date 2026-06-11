extends Node2D

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

@rpc("any_peer", "call_remote", "unreliable")
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

@rpc("any_peer", "call_remote", "unreliable")
func vibrate_player(player_id, duration_ms: int):
	rpc_id(player_id, "vibrate_player", duration_ms)

@rpc("any_peer", "call_remote", "unreliable")
func normal_coin_sound(player_id):
	rpc_id(player_id, "normal_coin_sound")

@rpc("any_peer", "call_remote", "unreliable")
func normal_damage_sound(player_id):
	rpc_id(player_id, "normal_damage_sound")

@rpc("any_peer", "call_remote", "unreliable")
func set_player_name(player_name: String):
	var player_id = multiplayer.get_remote_sender_id()
	
	if players.has(player_id):
		players[player_id].name_label.text = player_name
		print("Player: ", player_id, " name: ", player_name)


func vibrate_all_players(vibrate_time):
	rpc("vibrate_player", vibrate_time)
