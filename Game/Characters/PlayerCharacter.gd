extends Character

class_name PlayerCharacter

var xp: float = 0.0
var xp_to_next: float = Main.xp_required_to_reach_level(2)
var xp_progress: float = 0.0

var move_dir = Vector2.ZERO
const SPEED = 3.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var gun_sprite = $GunSprite
@onready var gunshot_sound = $GunshotSound
@onready var gun_windup_sound = $GunWindupSound

@onready var camera: Camera2D = $Camera2D

@onready var gui: CanvasLayer = $PlayerGUI

var state: Main.CharState = Main.CharState.IDLE

var last_shot: int = 0
var shoot_cd: float = 750.0

var gundir: Vector2 = Vector2.ZERO
var gunpos: Vector2 = Vector2.ZERO

var dead = false

const base_player_bullet_damage: float = 25.0
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
		char_sprite.flip_h = false

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

	position += move_dir * SPEED
	velocity = move_dir * SPEED

	if Input.is_action_pressed("shoot"):
		if Time.get_ticks_msec()-last_shot >= shoot_cd:
			gun_sprite.animation = "shoot"
			gun_sprite.play()
			gun_windup_sound.play()
			last_shot = Time.get_ticks_msec()
			
	if xp >= xp_to_next:
		level += 1
		level_up()

func _physics_process(delta):
	velocity *= 0.9
	move_and_slide()

func _on_gun_sprite_animation_looped():
	var new_bullet = bullet.instantiate()
	new_bullet.position = position + gunpos
	new_bullet.direction = gundir
	new_bullet.damage = base_player_bullet_damage * stat_bullet_damage_mult
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
