extends Node2D

var firstlevel: PackedScene = load("res://Game/Views/RandomFloor.tscn")
var player_scene: PackedScene = load("res://Game/Characters/Player.tscn")

@onready var charsprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var start_button: TextureButton = $Button
@onready var background: AnimatedSprite2D = $Background

# Called when the node enters the scene tree for the first time.
func _ready():
	Main.level = 1
	background.play()
	start_button.pivot_offset = start_button.size/2
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


func _on_button_mouse_entered():
	start_button.scale = Vector2.ONE * 1.1


func _on_button_mouse_exited():
	start_button.scale = Vector2.ONE
