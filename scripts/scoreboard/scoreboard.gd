extends Node2D

@onready var players_container = $Control/VBoxContainer/VBoxContainer
@onready var restart_button = $Control/RestartButton
@onready var background: AnimationPlayer = $Control/Background
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@export var music_paths: Array[String] = [
	"res://assets/music/scoreboard/Epic Win Song _ (Meme) [Audio].mp3",
	"res://assets/music/scoreboard/Victory Sound Effect.mp3",
	"res://assets/music/scoreboard/【CS2】Counter Strike 2 Soundtrack - Won Round.mp3",
]

func _ready():
	background.play("background_sea")
	play_random_music()
	display_scoreboard()


func play_random_music():
	if music_paths.is_empty():
		return
	
	var random_index = randi() % music_paths.size()
	var path = music_paths[random_index]
	
	var new_stream = load(path)
	if new_stream == null:
		print("❌ Falha ao carregar: ", path)
		return
	
	new_stream.loop = false
	music_player.stream = new_stream
	music_player.play()

func display_scoreboard():
	clear_container()
	
	var players_array = []
	for player_id in Global.players:
		var player = Global.players[player_id]
		players_array.append({
			"name": player.name_label.text if player.has_node("NameLabel") else "Player " + str(player_id),
			"points": player.points
		})
	
	players_array.sort_custom(func(a, b): return a.points > b.points)
	
	for player_data in players_array:
		var player_entry = HBoxContainer.new()
		
		var name_label = Label.new()
		name_label.text = player_data.name
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.add_theme_font_size_override("font_size", 72)
		
		var points_label = Label.new()
		points_label.text = str(player_data.points)
		points_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		points_label.add_theme_font_size_override("font_size", 72)
		
		player_entry.add_child(name_label)
		player_entry.add_child(points_label)
		players_container.add_child(player_entry)
		
		print("Added player: ", player_data.name, " - ", player_data.points)

func clear_container():
	for child in players_container.get_children():
		child.queue_free()

func _on_restart_button_pressed() -> void:
	Global.disable_players_physics()
	get_tree().change_scene_to_file("res://scenes/game_server.tscn")
