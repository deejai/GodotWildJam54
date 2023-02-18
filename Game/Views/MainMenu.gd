extends Node2D

@onready var charsprite: AnimatedSprite2D = $AnimatedSprite2D
var firstlevel: PackedScene = load("res://Game/Views/RandomFloor.tscn")
var player_scene: PackedScene = load("res://Game/Characters/Player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Main.music.set_track(MusicServer.Track.MENU)
	Main.floor_instance = null
	charsprite.play()
	Boons.reset()
	Curses.reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	for key in Curses.status:
		Curses.status[key] = 0

	Main.player = player_scene.instantiate()
	get_tree().change_scene_to_packed(firstlevel)
