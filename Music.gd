extends Node

@onready var main_player: AudioStreamPlayer = $MainLoopPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	main_player.play()
	print("go")
