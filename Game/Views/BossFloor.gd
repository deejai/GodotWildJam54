extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Main.music.set_track(MusicServer.Track.BOSS1)
	Main.floor_timer_begin(120.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass