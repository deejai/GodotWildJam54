extends Node2D

@onready var collide_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var particles: GPUParticles2D = $GPUParticles2D

const respawn_time: float = 2.0
var timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not particles.emitting:
		timer = max(0.0, timer - delta)
		if timer == 0.0:
			particles.emitting = true

func _on_area_2d_body_entered(body):
	if particles.emitting and body is EnemyCharacter and body.receive_damage(15.0):
		collide_sound.play()
		particles.emitting = false
		timer = respawn_time
