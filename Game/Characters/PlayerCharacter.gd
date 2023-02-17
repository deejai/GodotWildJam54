extends Character

class_name PlayerCharacter

var xp: float = 0.0
var xp_to_next: float = Main.xp_required_to_reach_level(2)
var xp_progress: float = 0.0

var move_dir = Vector2.ZERO
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var gun_sprite = $GunSprite
@onready var gunshot_sound = $GunshotSound
@onready var gun_windup_sound = $GunWindupSound

@onready var camera: Camera2D = $Camera2D

@onready var gui: CanvasLayer = $PlayerGUI

var state: Main.CharState = Main.CharState.IDLE

var gundir: Vector2 = Vector2.ZERO
var gunpos: Vector2 = Vector2.ZERO

var dead = false

const base_bullet_damage: float = 34.0
const base_speed: float = 3.0
const base_rof: float = 1.0

const gundist: float = 40.0

func _ready():
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
#		char_sprite.flip_h = false

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
	stat_bullet_damage_mult = 1.0 + 0.15 * (level-1)
	stat_damage_received_mult = 1.0 * pow(0.95,  (level-1))
	xp_to_next = Main.xp_required_to_reach_level(level + 1)
	hp = min(100.0, hp + 10.0)
	gain_xp(0.0)

func gain_xp(xp_gain: float):
	xp += xp_gain
	xp_progress = (xp - Main.xp_required_to_reach_level(level)) / (Main.xp_required_to_reach_level(level+1) - Main.xp_required_to_reach_level(level))

func calc_rate_of_fire():
	return base_rof * (stat_rof_mult + Boons.status["rate_of_fire"])

func calc_bullet_damage():
	return base_bullet_damage * (stat_bullet_damage_mult + Boons.status["bullet_damage"])

func calc_bullet_spread():
	return Boons.status["bullet_spread"]

func calc_lifesteal():
	return Boons.status["lifesteal"]

func calc_speed():
	return base_speed * (stat_speed_mult + Boons.status["speed"])
