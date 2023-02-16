extends CharacterBody2D

class_name Character

@export var alliance: Main.Alliance = Main.Alliance.NEUTRAL
@export var damage_received_mult: float = 1.0
@export var hurt_sounds: Array[AudioStreamWAV] = []
@export var char_sprite: AnimatedSprite2D
@export var bullet: PackedScene
var hp: float = 100.0

var invulnerable = false
var can_shoot = false

@export var stat_bullet_spread: int = 1
@export var stat_damage_received_mult: float = 1.0
@export var stat_speed_mult = 1.0
@export var stat_rof_mult = 1.0
@export var stat_damage_output_mult = 1.0
@export var stat_lifesteal = 0.0

var timers: Dictionary = {
	"flinch": {"value": 0.0,
		"activate": func():
			char_sprite.modulate = Color(1,0,0,1)
			if char_sprite.sprite_frames.has_animation("hit"):
				char_sprite.animation = "hit",
		"deactivate": func():
			char_sprite.modulate = Color(1,1,1,1)
			char_sprite.animation = "idle"
			},
	"invuln": {"value": 0.0, "activate": func(): invulnerable = true, "deactivate": func(): invulnerable = false},
	"ministun_cd": {"value": 0.0, "activate": func(): pass, "deactivate": func(): pass},
	"shoot": {"value": 0.0, "activate": func(): can_shoot = false, "deactivate": func(): can_shoot = true},
}

func engage_timer(key: String, time: float):
	assert(time >= 0.0)

	var engaged: bool = false

	if time == 0.0:
		return false

	var timer = timers[key]
	if timer.value == 0.0:
		timer.activate.call()
		timer.value = max(timer.value, time)
		return true

	return false

func char_process(delta):
	for key in timers:
		var timer = timers[key]
		if timer.value > 0.0:
			timer.value = max(0.0, timer.value-delta)
			if timer.value == 0.0:
				timer.deactivate.call()

func receive_damage(amount: float):
	if invulnerable:
		return false

	hp = max(0.0, hp - amount * damage_received_mult)

	engage_timer("flinch", 0.15)
	engage_timer("invuln", 0.5)
	Main.play_random_sound(hurt_sounds, global_position)

	if hp <= 0.0:
		if not self is PlayerCharacter:
			queue_free()

	return true

func ministun(collision_pos: Vector2):
	if engage_timer("ministun_cd", 0.5):
		position += collision_pos.direction_to(position) * 10.0
