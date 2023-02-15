extends Node2D

@onready var charsprite: AnimatedSprite2D = $AnimatedSprite2D
var firstlevel: PackedScene = load("res://Demo.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	charsprite.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	get_tree().change_scene_to_packed(firstlevel)
