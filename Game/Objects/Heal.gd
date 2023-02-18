extends Node2D

@export var pickup_sound: AudioStreamWAV

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	if body is PlayerCharacter and body.hp < 100.0:
		body.hp = min(100.0, body.hp + 20.0)
		Main.play_random_sound([pickup_sound], global_position)
		queue_free()
