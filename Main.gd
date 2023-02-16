extends Node

enum Alliance {NEUTRAL, PLAYER, ENEMY}
enum CharState {IDLE, WALKING}

var audio_players: Array[AudioStreamPlayer2D] = []
var audio_player_index: int = 0
const num_audio_players: int = 16

var level = 0

var player = load("res://Game/Characters/Player.tscn").instantiate()
var random_floor_scene: PackedScene = load("res://RandomFloor.tscn")

var floor_instance: Node = null

var music_server: Node = load("res://Music.tscn").instantiate()

func play_random_sound(array: Array[AudioStreamWAV], position):
	var arr_len = len(array)
	var audio_player = audio_players[audio_player_index]
	if arr_len > 0:
		audio_player.position = position
		audio_player.stream = array[randi() % arr_len]
		audio_player.play(0.0)
		
		audio_player_index = (audio_player_index + 1) % num_audio_players

func descend():
		floor_instance.remove_child(Main.player)
		Main.level += 1
		get_tree().change_scene_to_packed(Main.random_floor_scene)

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(music_server)

	for i in range(num_audio_players):
		var audio_player = AudioStreamPlayer2D.new()
		add_child(audio_player)
		audio_players.append(audio_player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
