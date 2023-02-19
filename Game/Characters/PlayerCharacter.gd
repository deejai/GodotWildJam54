extends Character

class_name PlayerCharacter

var xp: float = 0.0
var xp_to_next: float = Main.xp_required_to_reach_level(2)
var xp_progress: float = 0.0

var move_dir = Vector2.ZERO

var fireball_scene: PackedScene = load("res://Game/Objects/Projectiles/Fireball.tscn")

@onready var gun_sprite = $GunSprite
@onready var gunshot_sound = $GunshotSound
@onready var gun_windup_sound = $GunWindupSound
@onready var teleport_sound = $TeleportSound
@onready var fireball_engage = $FireballEngage
@onready var fireball_disengage = $FireballDisengage
@onready var fireball_loop = $FireballLoop

@onready var camera: Camera2D = $Camera2D

@onready var gui: CanvasLayer = $PlayerGUI

@onready var fireball_platter: Node2D = $FireballPlatter

var state: Main.CharState = Main.CharState.IDLE

var gundir: Vector2 = Vector2.ZERO
var gunpos: Vector2 = Vector2.ZERO

var dead = false

const base_bullet_damage: float = 34.0
const base_speed: float = 3.0
const base_rof: float = 1.0

const gundist: float = 40.0

var fireballs: Array = []

@onready var items_node: Node = $Items
var slot_q: Item = null
var slot_e: Item = null

func _ready():
	char_ready()
	char_sprite.play()

func _process(delta):
	if dead:
		return

	char_process(delta)

	gundir = (get_global_mouse_position() - position).normalized()
	gunpos = gundir * gundist

	gun_sprite.position = gunpos
	gun_sprite.rotation = gundir.angle()
	
	if gun_sprite.rotation > PI/2 or gun_sprite.rotation < -PI/2:
		gun_sprite.flip_v = true
		char_sprite.flip_h = true
	else:
		gun_sprite.flip_v = false
		char_sprite.flip_h = false

	if slot_e != null and Input.is_action_just_pressed("Drop E"):
		slot_e.drop()

	if slot_q != null and Input.is_action_just_pressed("Drop Q"):
		slot_q.drop()

	var dir_x: float = 0.0
	var dir_y: float = 0.0
	if Input.is_action_pressed("move_up"):
		dir_y -= 1.0
	if Input.is_action_pressed("move_down"):
		dir_y += 1.0
	if Input.is_action_pressed("move_left"):
		dir_x -= 1.0
	if Input.is_action_pressed("move_right"):
		dir_x += 1.0

	move_dir = Vector2(dir_x, dir_y).normalized()

	if Curses.status["reverse_controls"] > 0:
		move_dir *= -1

	if Curses.status["random_teleport"] and randf() > 1.0 - (.35 * delta):
		position += Vector2([-1.0, 1.0].pick_random(), [-1.0, 1.0].pick_random()) * randf_range(20.0, 50.0)
		teleport_sound.play()

	if Curses.status["hp_drain"] and randf() > 1.0 - (.35 * delta):
		receive_damage(randf_range(1.5, 3.5) / (stat_damage_received_mult + .3 * Curses.deals_with_the_devil))

	if timers["flinch"].value == 0.0:
		if move_dir == Vector2.ZERO:
			char_sprite.animation = "idle"
		else:
			char_sprite.animation = "walk"

	var speed = calc_speed()
	position += move_dir * speed
	velocity = move_dir * speed

	if Input.is_action_pressed("shoot"):
		if engage_timer("shoot", 1.0/calc_rate_of_fire()):
			gun_sprite.animation = "shoot"
			gun_sprite.play()
			gun_windup_sound.play()

	fireball_platter.rotation += delta * PI * .6

	var n_fireballs = calc_fireballs()
	var fireball_diff = n_fireballs - len(fireballs)
	if fireball_diff != 0:
		if fireball_diff > 0:
			fireball_loop.play()
			fireball_engage.play()
		else:
			fireball_loop.stop()
			fireball_disengage.play()
			
		for i in range(fireball_diff):
			var new_fireball = fireball_scene.instantiate()
			fireball_platter.add_child(new_fireball)
			fireballs.append(new_fireball)
		for i in range(-fireball_diff):
			fireballs.pop_back().queue_free()

		for i in range(n_fireballs):
			fireballs[i].position = Vector2.ONE.rotated(i * 2.0 * PI / n_fireballs) * 85.0

	if xp >= xp_to_next:
		level += 1
		level_up()

func _physics_process(delta):
	velocity *= 0.9
	move_and_slide()

func _on_gun_sprite_animation_looped():
	var num_bullets: int = 1 + calc_bullet_spread()
	for i in range(num_bullets):
		var new_bullet = bullet.instantiate()
		new_bullet.position = position + gunpos
		const ind_spred = PI/12.0
		new_bullet.direction = gundir.rotated(-(num_bullets / 2) * ind_spred + i * ind_spred)
		new_bullet.damage = calc_bullet_damage()
		new_bullet.shooter = self
		new_bullet.lifesteal = calc_lifesteal()
		get_parent().add_child(new_bullet)
	gunshot_sound.play()
	gun_sprite.stop() # Replace with function body.
	gun_sprite.animation = "idle"

func level_up():
	gui.show_level_up()
	Main.music.play_level_up_sound()
	stat_bullet_damage_mult = 1.0 + 0.05 * (level-1)
	stat_damage_received_mult = 1.0 * pow(0.95,  (level-1))
	stat_rof_mult = 1.0 + 0.05 * (level-1)
	stat_speed_mult = 1.0 + 0.05 * (level-1)
	xp_to_next = Main.xp_required_to_reach_level(level + 1)
	hp = min(100.0, hp + 10.0)
	gain_xp(0.0)

func gain_xp(xp_gain: float):
	xp += xp_gain
	xp_progress = (xp - Main.xp_required_to_reach_level(level)) / (Main.xp_required_to_reach_level(level+1) - Main.xp_required_to_reach_level(level))

func calc_rate_of_fire():
	return (base_rof + Boons.status["rate_of_fire"]) * stat_rof_mult

func calc_bullet_damage():
	return (base_bullet_damage + Boons.status["bullet_damage"]) * stat_bullet_damage_mult

func calc_bullet_spread():
	return Boons.status["bullet_spread"]

func calc_lifesteal():
	return Boons.status["lifesteal"]

func calc_speed():
	return (base_speed + Boons.status["speed"]) * stat_speed_mult

func calc_fireballs():
	return Boons.status["fireballs"] + 4 * Curses.deals_with_the_devil
