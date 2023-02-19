extends CharacterBody2D

class_name Character

@export var level: int = 1

@export var alliance: Main.Alliance = Main.Alliance.NEUTRAL
@export var hurt_sounds: Array[AudioStreamWAV] = []
@export var death_sounds: Array[AudioStreamWAV] = []
@export var aggro_sounds: Array[AudioStreamWAV] = []
@export var walk_sounds: Array[AudioStreamWAV] = []
@export var char_sprite: AnimatedSprite2D
@export var bullet: PackedScene
var hp: float = 100.0

var invulnerable = false

var can_melee: bool = false

var stat_damage_received_mult: float = 1.0
var stat_speed_mult: float = 1.0
var stat_rof_mult: float = 1.0
var stat_bullet_damage_mult: float = 1.0
var stat_lifesteal: float = 0.0
var stat_melee_damage: float = 30.0
var stat_melee_cd: float = 1.5

@onready var light: Node2D = load("res://Game/Objects/CharLight.tscn").instantiate()

var blood_splatter: PackedScene = load("res://Game/Objects/BloodSplatter.tscn")
var hit_marker: PackedScene = load("res://Game/Objects/HitMarker.tscn")

var timers: Dictionary = {
	"flinch": {"value": 0.0,
		"activate": func():
			if char_sprite.sprite_frames.has_animation("hit"):
				char_sprite.animation = "hit",
		"deactivate": func():
			char_sprite.animation = "idle"
			},
	"damage_rate_limiter": {"value": 0.0,
		"activate": func():
			char_sprite.modulate = Color(1,.5,.5,1),
		"deactivate": func():
			char_sprite.modulate = Color(1,1,1,1)
			},
	"ministun_cd": {"value": 0.0},
	"shoot": {"value": 0.0},
}

func engage_timer(key: String, time: float):
	assert(time >= 0.0)

	if time == 0.0:
		return false

	var timer = timers[key]
	if timer.value == 0.0:
		if "activate" in timer:
			timer.activate.call()
		timer.value = max(timer.value, time)
		return true

	return false

func char_ready():
	add_child(light)

func char_process(delta):
	for key in timers:
		var timer = timers[key]
		if timer.value > 0.0:
			timer.value = max(0.0, timer.value-delta)
			if timer.value == 0.0 and "deactivate" in timer:
				timer.deactivate.call()

	if hp <= 0.0:
		if self is PlayerCharacter and not self.dead:
			Main.floor_timer_enabled = false
			self.gui.youdied.button_enable_timer = 2.0
			self.dead = true
			self.visible = false
			self.get_node("PlayerGUI/YouDied").visible = true
			Boons.reset()
			Curses.reset()
			Main.music.stop()
			Main.death_jingle.play()
			Main.play_random_sound(death_sounds, global_position)
			var new_blood_splatter = blood_splatter.instantiate()
			new_blood_splatter.position = global_position
			Main.floor_instance.add_child(new_blood_splatter)
		else:
			if self is EnemyCharacter:
				if not self.is_summon:
					Main.player.gain_xp(self.stat_xp_reward)
				if self.is_the_boss and Main.floor_instance is BossFloor:
					Main.floor_instance.boss_defeated = true
			Main.play_random_sound(death_sounds, global_position)
			var new_blood_splatter = blood_splatter.instantiate()
			new_blood_splatter.position = global_position
			Main.floor_instance.add_child(new_blood_splatter)
			queue_free()

func receive_damage(amount: float):
	if not engage_timer("damage_rate_limiter", .15):
		return false

	if engage_timer("flinch", .3):
		Main.play_random_sound(hurt_sounds, global_position)

	var damage = amount * stat_damage_received_mult
	if self is PlayerCharacter:
		damage += amount * .3 * Curses.deals_with_the_devil

	hp = max(0.0, hp - damage)

	return true

func ministun(collision_pos: Vector2):
	var marker = hit_marker.instantiate()
	marker.position = collision_pos - global_position
	add_child(marker)
	if engage_timer("ministun_cd", 0.5):
		position += collision_pos.direction_to(position) * 10.0
