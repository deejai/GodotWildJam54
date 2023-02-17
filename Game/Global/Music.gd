extends Node

@onready var main_player: AudioStreamPlayer = $MainLoopPlayer
@onready var level_up_player: AudioStreamPlayer = $LevelUpPlayer

var resume_volume: float

# Called when the node enters the scene tree for the first time.
func _ready():
	main_player.play()

func play_level_up_sound():
	resume_volume = main_player.volume_db
	main_player.volume_db -= 12
	level_up_player.play()

func _on_level_up_player_finished():
	main_player.volume_db = resume_volume
