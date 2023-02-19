extends Node2D

@onready var frect: ColorRect = $FRect
@onready var area2d: Area2D = $Area2D

@export var sign_sound: AudioStreamWAV

# Called when the node enters the scene tree for the first time.
func _ready():
	frect.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if frect.visible and Input.is_action_just_pressed("Sign"):
		Main.play_random_sound([sign_sound], global_position)
		Curses.deals_with_the_devil += 1
		queue_free()

	scale = Vector2.ONE * (.85 + .1 * absf((500 - Time.get_ticks_msec() % 1000) / 1000.0))
	area2d.scale = Vector2.ONE / scale

func _on_area_2d_body_entered(body):
	if body is PlayerCharacter:
		frect.visible = true


func _on_area_2d_body_exited(body):
	if body is PlayerCharacter:
		frect.visible = false
