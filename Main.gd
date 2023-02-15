extends Node

enum Alliance {NEUTRAL, PLAYER, ENEMY}
enum CharState {IDLE, WALKING}

var audio_players: Array[AudioStreamPlayer2D] = []
var audio_player_index: int = 0
const num_audio_players: int = 16

func play_random_sound(array: Array[AudioStreamWAV], position):
	var arr_len = len(array)
	var audio_player = audio_players[audio_player_index]
	if arr_len > 0:
		audio_player.position = position
		audio_player.stream = array[randi() % arr_len]
		audio_player.play(0.0)
		
		audio_player_index = (audio_player_index + 1) % num_audio_players

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(num_audio_players):
		var audio_player = AudioStreamPlayer2D.new()
		add_child(audio_player)
		audio_players.append(audio_player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
