extends AnimatedSprite2D

class_name Bullet

@export var lifetime: float = .5
@export var damage: float = 10.0
@export var dangerous_to: Main.Alliance = Main.Alliance.ENEMY
@export var impact_sounds: Array[AudioStreamWAV] = []
@export var ministun: bool = true
@export var speed: float = 500.0
var direction: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += delta * direction * speed
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_area_2d_body_entered(body):
	if body is Character and dangerous_to == body.alliance:
		if body is EnemyCharacter and not body.is_target_valid():
			body.target = Main.player
		if body.receive_damage(damage):
			body.ministun(position)
			Main.play_random_sound(impact_sounds, global_position)
			queue_free()
	elif not body is Character:
		queue_free()
