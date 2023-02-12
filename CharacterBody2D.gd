extends CharacterBody2D

var move_dir = Vector2.ZERO
const SPEED = 3.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var gunsprite = $GunSprite
@onready var charsprite = $CharacterSprite
@onready var gunshot_sound = $GunshotSound

var last_shot: int = 0
var shoot_cd: int = 750

@onready var bullet = load("res://Bullet.tscn")

const gundist: float = 40.0

func _ready():
	charsprite.play()

func _process(delta):
	var mousepos = get_global_mouse_position()
	var gundir = (mousepos - position).normalized()
	var gunpos = gundir * gundist

	gunsprite.position = gunpos
	gunsprite.rotation = gundir.angle()
	
	if gunsprite.rotation > PI/2 or gunsprite.rotation < -PI/2:
		gunsprite.flip_v = true
	else:
		gunsprite.flip_v = false

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

	position += move_dir * SPEED
	
	if Input.is_action_just_pressed("shoot") and Time.get_ticks_msec()-last_shot >= shoot_cd:
		var new_bullet = bullet.instantiate()
		new_bullet.position = gunpos
		new_bullet.direction = gundir
		add_child(new_bullet)
		gunshot_sound.play()
		last_shot = Time.get_ticks_msec()

func _input(event):
	if event is InputEventKey:
		print(event)

func _physics_process(delta):
	move_and_slide()
