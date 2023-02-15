extends Character

class_name PlayerCharacter

var move_dir = Vector2.ZERO
const SPEED = 3.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var gun_sprite = $GunSprite
@onready var char_sprite = $CharacterSprite
@onready var gunshot_sound = $GunshotSound
@onready var gun_windup_sound = $GunWindupSound

var state: Main.CharState = Main.CharState.IDLE

var last_shot: int = 0
var shoot_cd: int = 750

var gundir: Vector2 = Vector2.ZERO
var gunpos: Vector2 = Vector2.ZERO

@onready var bullet = load("res://Game/Objects/Bullet.tscn")

const gundist: float = 40.0

func _ready():
	char_sprite.play()

func _process(delta):
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
	
	if move_dir == Vector2.ZERO:
		char_sprite.animation = "idle"
	else:
		char_sprite.animation = "walk"

	position += move_dir * SPEED
	
	if Input.is_action_pressed("shoot"):
		if Time.get_ticks_msec()-last_shot >= shoot_cd:
			gun_sprite.animation = "shoot"
			gun_sprite.play()
			gun_windup_sound.play()
			last_shot = Time.get_ticks_msec()

func _physics_process(delta):
	move_and_slide()

func _on_gun_sprite_animation_looped():
	var new_bullet = bullet.instantiate()
	new_bullet.position = gunpos
	new_bullet.direction = gundir
	add_child(new_bullet)
	gunshot_sound.play()
	gun_sprite.stop() # Replace with function body.
	gun_sprite.animation = "idle"
