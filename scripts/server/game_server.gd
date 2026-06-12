extends Node2D

@export var player_scene = preload("res://scenes/nave/nave.tscn")
@export var vibrate_time_end_game: int = 1000

@onready var ball_manager = $BallManager
@onready var powerups_manager = $PowerupManager
@onready var timer_label: Label = $UiManager/TimerLabel
@onready var game_timer: Timer = $UiManager/TimerLabel/Timer
@onready var music_player: AudioStreamPlayer = $MusicPlayer

var players = {}
var default_posiion = Vector2(0, 0)

func _input(event):
	if event.is_pressed() && game_timer.is_stopped():
		start_game()
	if event.is_action_pressed("reset_game"):
		reset_game()

func _process(delta):
	if !game_timer.is_stopped():
		update_timer_display()

func update_timer_display():
	var minutes = int(game_timer.time_left) / 60
	var seconds = int(game_timer.time_left) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

func end_game():
	print("END!")
	Global.vibrate_all_players(vibrate_time_end_game)
	
	if ball_manager:
		ball_manager.stop_spawning()
	if powerups_manager:
		powerups_manager.stop_spawning()

func reset_game():
	if ball_manager:
		ball_manager.stop_spawning()
	if powerups_manager:
		powerups_manager.stop_spawning()
	
	game_timer.stop()
	timer_label.text = "05:00"
	music_player.stop()

func start_game():
	game_timer.start()

	if ball_manager:
		ball_manager.start_spawning()
	
	if powerups_manager:
		powerups_manager.start_spawning()
	
	music_player.play()
	music_player.autoplay = true
