extends Node

class_name MusicServer

enum Track {DUNGEON1, DUNGEON2, BOSS1, BOSS2, BOSS3, MENU}
enum Mode {TRACK, STEMS}

@onready var level_up_player: AudioStreamPlayer = $LevelUpPlayer

var resume_volume: float = -1.0
var resume_track: Track

var mode = Mode.TRACK

var stopped = false

var current_track: Track = Track.MENU

@onready var trackdict: Dictionary = {
	Track.BOSS1: $BossMusic1,
	Track.BOSS2: $BossMusic2,
	Track.BOSS3: $BossMusic3,
	Track.MENU: $MenuMusic,
}

@onready var stems: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	for stemplayer in $Stems.get_children():
		stemplayer.volume_db = -12
		stems.append(stemplayer)

func _process(delta):
#	if mode == Mode.STEMS and randf() < .14 * delta:
#		play_random_stems()
	pass

func play_level_up_sound():
	if resume_volume == -1.0 and mode == Mode.STEMS:
		resume_track = current_track
		resume_volume = trackdict[current_track].volume_db
		trackdict[current_track].volume_db -= 12

	level_up_player.play()

func _on_level_up_player_finished():
	trackdict[resume_track].volume_db = resume_volume
	resume_volume = -1.0

func stop():
	var stopped = true
	if mode == Mode.TRACK:
		trackdict[current_track].stop()
	else:
		for stem in stems:
			stem.stop()

func set_track(track: Track):
	var stopped = false
	stop()
	mode = Mode.TRACK

	for key in trackdict:
		if key != track:
			trackdict[key].stop()

	trackdict[track].play()
	current_track = track

func play_random_stems():
	var stopped = false
	if mode == Mode.TRACK:
		stop()
		mode = Mode.STEMS

	for stem in stems:
		stem.play()
		stem.volume_db = -12

	var chosen_stems = stems.duplicate()
	chosen_stems.shuffle()
	for i in range(randi_range(4,5)):
		var excluded_stem = chosen_stems.pop_front()
		excluded_stem.volume_db = -100

