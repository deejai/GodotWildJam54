extends Node

enum Alliance {NEUTRAL, PLAYER, ENEMY}
enum CharState {IDLE, WALKING}

var audio_players: Array[AudioStreamPlayer2D] = []
var audio_player_index: int = 0
const num_audio_players: int = 16

var level = 1

var player
var random_floor_scene: PackedScene = load("res://Game/Views/RandomFloor.tscn")

var floor_instance: Node = null

var music: Node = load("res://Game/Global/Music.tscn").instantiate()

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
		get_tree().change_scene_to_packed(random_floor_scene)
		player.gui.fade_transition()

# Called when the node enters the scene tree for the first time.
func _ready():
	for key in Curses.status:
		assert(key in Curses.description)

	add_child(music)

	for i in range(num_audio_players):
		var audio_player = AudioStreamPlayer2D.new()
		add_child(audio_player)
		audio_players.append(audio_player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func xp_required_to_reach_level(target_level: int):
	if target_level <= 1:
		return 0

	return 100.0 * (target_level-1) * pow(1.1, target_level-2)
