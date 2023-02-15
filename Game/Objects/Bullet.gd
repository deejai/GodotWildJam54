extends AnimatedSprite2D

@export var lifetime: float = 2.0
@export var damage: float = 35.0
@export var dangerous_to: Main.Alliance = Main.Alliance.ENEMY
@export var impact_sounds: Array[AudioStreamWAV] = []
var direction: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += direction * 10.0
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_area_2d_body_entered(body):
	if body is Character and dangerous_to == body.alliance:
		body.receive_damage(damage)
		Main.play_random_sound(impact_sounds, global_position)
		queue_free()
	elif not body is Character:
		queue_free()
