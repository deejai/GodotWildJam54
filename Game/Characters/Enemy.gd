extends Character

var target: PlayerCharacter = null
var speed: float = 50.0
var nav_cd: float = 2.0
var last_nav_pos: Vector2 = Vector2.ZERO

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var hp_bar: ProgressBar = $ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	nav_agent

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	hp_bar.value = hp
	hp_bar.visible = hp < 100.0

	nav_cd = max(0.0, nav_cd - delta)

	if nav_cd == 0.0 and is_instance_valid(target) and target.position != last_nav_pos:
		last_nav_pos = target.position
		nav_agent.set_target_position(target.position)

func _physics_process(delta):
	if is_instance_valid(target):
		var next_pos = nav_agent.get_next_path_position()
		velocity = (target.position - position).normalized() * speed

	move_and_slide()

func _on_aggro_area_body_entered(body):
	if body is PlayerCharacter:
		target = body

func _on_aggro_area_body_exited(body):
	if body is PlayerCharacter:
		target = null
		velocity = Vector2.ZERO
