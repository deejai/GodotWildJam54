extends Node2D

@onready var main_menu_scene = load("res://Game/Views/MainMenu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()
	Main.music.stop()
	$AudioStreamPlayer.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	get_tree().change_scene_to_packed(main_menu_scene)
