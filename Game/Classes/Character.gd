extends CharacterBody2D

class_name Character

@export var alliance: Main.Alliance = Main.Alliance.NEUTRAL
@export var damage_received_mult: float = 1.0
@export var hurt_sounds: Array[AudioStreamWAV] = []
var hp: float = 100.0

func receive_damage(amount: float):
	hp = max(0.0, hp - amount * damage_received_mult)
	Main.play_random_sound(hurt_sounds, global_position)
	if hp <= 0.0:
		queue_free()
