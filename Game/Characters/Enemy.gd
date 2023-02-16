extends Character

var target: PlayerCharacter = null
var speed: float = 50.0
var nav_cd: float = 2.0
var last_nav_pos: Vector2 = Vector2.ZERO

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var hp_bar: ProgressBar = $ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	char_sprite.play()
	engage_timer("shoot", 2.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	char_process(delta)

	hp_bar.value = hp
	hp_bar.visible = hp < 100.0

	nav_cd = max(0.0, nav_cd - delta)

	if nav_cd == 0.0 and is_instance_valid(target) and target.position != last_nav_pos:
		last_nav_pos = target.position
		nav_agent.set_target_position(target.position)
		
	if bullet and is_instance_valid(target) and engage_timer("shoot", 1.0 / stat_rof_mult):
		var new_bullet: Bullet = bullet.instantiate()
		new_bullet.position = position
		new_bullet.dangerous_to = Main.Alliance.PLAYER
		new_bullet.direction = position.direction_to(target.position)
		get_parent().add_child(new_bullet)

func _physics_process(delta):
	if is_instance_valid(target):
		var next_pos = nav_agent.get_next_path_position()
		velocity = (target.position - position).normalized() * speed
		char_sprite.flip_h = target.position.x < position.x

	for i in range(get_slide_collision_count()):
	# We get one of the collisions with the player
		var collision = get_slide_collision(i)
		
		var body = collision.get_collider()
		if body is PlayerCharacter:
			body.receive_damage(10.0)
			body.ministun(position)

	move_and_slide()

func _on_aggro_area_body_entered(body):
	if body is PlayerCharacter:
		target = body

func _on_aggro_area_body_exited(body):
	if body is PlayerCharacter:
		target = null
		velocity = Vector2.ZERO
