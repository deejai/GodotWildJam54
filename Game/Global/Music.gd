extends Node

class_name MusicServer

enum Track {DUNGEON1, DUNGEON2, BOSS1, BOSS2, BOSS3, MENU}

@onready var level_up_player: AudioStreamPlayer = $LevelUpPlayer

var resume_volume: float = -1.0
var resume_track: Track

var current_track: Track = Track.MENU

@onready var trackdict: Dictionary = {
	Track.DUNGEON1: $DungeonMusic1,
	Track.DUNGEON2: $DungeonMusic2,
	Track.BOSS1: $BossMusic1,
	Track.BOSS2: $BossMusic2,
	Track.BOSS3: $BossMusic3,
	Track.MENU: $MenuMusic,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE

func play_level_up_sound():
	if resume_volume != -1.0:
		return

	resume_track = current_track
	resume_volume = trackdict[current_track].volume_db
	trackdict[current_track].volume_db -= 12
	level_up_player.play()

func _on_level_up_player_finished():
	trackdict[resume_track].volume_db = resume_volume
	resume_volume = -1.0

func stop():
	trackdict[current_track].stop()

func set_track(track: Track):	
	for key in trackdict:
		if key != track:
			trackdict[key].stop()

	trackdict[track].play()
	current_track = track
