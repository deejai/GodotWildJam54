extends Node2D

@export var pickup_sound: AudioStreamWAV

@onready var small_heal: TextureRect = $SmallHeal
@onready var medium_heal: TextureRect = $MediumHeal
@onready var big_heal: TextureRect = $BigHeal

var image: TextureRect
var heal_amount: float

# Called when the node enters the scene tree for the first time.
func _ready():
	var choice_index = [0,1,2].pick_random()
	image = [small_heal, medium_heal, big_heal][choice_index]
	heal_amount = [15.0, 30.0, 45.0][choice_index]
	image.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	if body is PlayerCharacter and body.hp < 100.0:
		body.hp = min(100.0, body.hp + heal_amount)
		Main.play_random_sound([pickup_sound], global_position)
		queue_free()
