extends Node

enum Alliance {NEUTRAL, PLAYER, ENEMY}
enum CharState {IDLE, WALKING}

var audio_players: Array[AudioStreamPlayer2D] = []
var audio_player_index: int = 0
const num_audio_players: int = 16

var level = 1

var player
var random_floor_scene: PackedScene = load("res://Game/Views/RandomFloor.tscn")
var boss_floor_scene1: PackedScene = load("res://Game/Views/BossFloor1.tscn")
var boss_floor_scene2: PackedScene = load("res://Game/Views/BossFloor2.tscn")
var boss_floor_scene3: PackedScene = load("res://Game/Views/BossFloor3.tscn")
var victory_scene: PackedScene = load("res://Game/Views/VictoryScene.tscn")

var floor_instance: Node = null

var music: Node = load("res://Game/Global/Music.tscn").instantiate()
var main_scene = load("res://Game/Global/Main.tscn").instantiate()
var collapsed_ending_scene = load("res://Game/Views/CollapsedEnding.tscn")

var paused: bool = false

@onready var pause_menu: CanvasLayer = main_scene.get_node("PauseMenu")
@onready var pause_sound: AudioStreamPlayer = main_scene.get_node("PauseSound")

@onready var death_jingle: AudioStreamPlayer = main_scene.get_node("DeathJingle")
@onready var descend_sound: AudioStreamPlayer = main_scene.get_node("DescendSound")
@onready var victory_sound: AudioStreamPlayer = main_scene.get_node("VictorySound")

const boss_floor_cadence = 4

var floor_timer: float
var floor_timer_enabled: bool = false

func play_random_sound(array: Array[AudioStreamWAV], position, volume_db=0.0):
	var arr_len = len(array)
	var audio_player = audio_players[audio_player_index]
	if arr_len > 0:
		audio_player.volume_db = volume_db
		audio_player.position = position
		audio_player.stream = array[randi() % arr_len]
		audio_player.play(0.0)

		audio_player_index = (audio_player_index + 1) % num_audio_players

func descend():
		floor_timer_enabled = false
		descend_sound.play()
		floor_instance.remove_child(Main.player)
		floor_instance.queue_free()
		level += 1
		if level == boss_floor_cadence * 1:
			get_tree().change_scene_to_packed(boss_floor_scene1)
		elif level == boss_floor_cadence * 2:
			get_tree().change_scene_to_packed(boss_floor_scene2)
		elif level == boss_floor_cadence * 3:
			get_tree().change_scene_to_packed(boss_floor_scene3)
		elif level == 1 + boss_floor_cadence * 3:
			get_tree().change_scene_to_packed(victory_scene)
		else:
			get_tree().change_scene_to_packed(random_floor_scene)

		player.gui.fade_transition()

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_menu.visible = false
	add_child(main_scene)
	process_mode = Node.PROCESS_MODE_ALWAYS
	for key in Curses.status:
		assert(key in Curses.description)

	add_child(music)

	for i in range(num_audio_players):
		var audio_player = AudioStreamPlayer2D.new()
		add_child(audio_player)
		audio_players.append(audio_player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if floor_instance!= null and Input.is_action_just_pressed("Pause"):
		set_pause(!paused)

	if floor_timer_enabled and !paused:
		floor_timer = max(0.0, floor_timer - delta)
		if floor_timer == 0.0:
			floor_timer_enabled = false
			get_tree().change_scene_to_packed(collapsed_ending_scene)

func xp_required_to_reach_level(target_level: int):
	if target_level <= 1:
		return 0

	return 100.0 * (target_level-1) * pow(1.3, target_level-2)

func set_pause(val: bool):
	paused = val
	get_tree().paused = val
	pause_menu.visible = val
	pause_sound.play()

func floor_timer_begin(time_limit: float):
	floor_timer_enabled = true
	floor_timer = time_limit
