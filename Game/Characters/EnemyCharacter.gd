extends Character

class_name EnemyCharacter

@export var type: EnemyStats.Type

var stat_xp_reward: float = 10.0

var target = null
var speed: float = 50.0
var nav_cd: float = 2.0
var last_nav_pos: Vector2 = Vector2.ZERO

var has_aggroed: bool = false

var is_summon: bool = false
var expires: bool = false
var time_remaining: float = 0.0

@export var is_the_boss: bool = false

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var hp_bar: ProgressBar = $ProgressBar

@export var shoot_sounds: Array[AudioStreamWAV]

# Called when the node enters the scene tree for the first time.
func _ready():
	char_ready()
	char_sprite.play()
	engage_timer("shoot", 2.0)
	timers["melee_cd"] = {"value": 0.0}
	can_melee = true

	EnemyStats.setup_stats(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Main.floor_instance is BossFloor and Main.floor_instance.boss_defeated:
		hp = 0

	if expires:
		time_remaining -= delta
		if time_remaining <= 0.0:
			hp = 0

	char_process(delta)

	hp_bar.value = hp
	hp_bar.visible = hp < 100.0

	nav_cd = max(0.0, nav_cd - delta)

	if nav_cd == 0.0 and is_target_valid() and target.position != last_nav_pos:
		last_nav_pos = target.position
		nav_agent.set_target_position(target.position)

	if bullet and is_target_valid() and engage_timer("shoot", 1.0 / stat_rof_mult):
		var new_bullet: Bullet = bullet.instantiate()
		new_bullet.damage = new_bullet.damage * stat_bullet_damage_mult
		new_bullet.position = position
		new_bullet.dangerous_to = Main.Alliance.PLAYER
		new_bullet.direction = position.direction_to(target.position)
		Main.play_random_sound(shoot_sounds, global_position, -7.0 if type in [EnemyStats.Type.BLUEBERRY_FLY_A, EnemyStats.Type.BLUEBERRY_FLY_B] else -5.0)
		get_parent().add_child(new_bullet)

	if type in [EnemyStats.Type.TOMATO, EnemyStats.Type.BOSS3]:
		if is_target_valid() and timers["ministun_cd"].value == 0.0 and target.position.distance_to(position) < 200.0:
			char_sprite.animation = "attack"
		else:
			char_sprite.animation = "idle"
			
		char_sprite.offset.x = 40 * -1.0 if char_sprite.flip_h else 1.0

func _physics_process(delta):
	if is_target_valid():
		var next_pos = nav_agent.get_next_path_position()
		var bonus_mult = 3.5 if (type in [EnemyStats.Type.TOMATO, EnemyStats.Type.BOSS3] and timers["ministun_cd"].value == 0.0 and target.position.distance_to(position) < 200.0) else 1.0
		velocity = (target.position - position).normalized() * speed * stat_speed_mult * 2.0 * bonus_mult * delta * 75
		char_sprite.flip_h = target.position.x < position.x

	if can_melee and timers["melee_cd"].value == 0.0:
		for i in range(get_slide_collision_count()):
		# We get one of the collisions with the player
			var collision = get_slide_collision(i)

			var body = collision.get_collider()
			if body is PlayerCharacter:
				if body.receive_damage(stat_melee_damage):
					engage_timer("melee_cd", stat_melee_cd)
					body.ministun(position)
					position += body.position.direction_to(position) * 15.0
				break

	move_and_slide()

func _on_aggro_area_body_entered(body):
	if body is PlayerCharacter and body.dead == false:
		target = body
		if not has_aggroed:
			Main.play_random_sound(aggro_sounds, global_position)
			has_aggroed = true

func _on_aggro_area_body_exited(body):
	if body is PlayerCharacter:
		target = null
		velocity = Vector2.ZERO

func is_target_valid():
	if is_instance_valid(target):
		if target.dead:
			target = null
			return false
		else:
			return true
			
	return false


func _on_animated_sprite_2d_animation_looped():
	if char_sprite.animation == "idle":
		Main.play_random_sound(walk_sounds, global_position, -6.0)
