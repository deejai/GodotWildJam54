extends Node

class_name Item

@export var curse_key: String = ""
@export var boons: Array[Dictionary] = []

@onready var description_label: RichTextLabel = $Description

func pickup(player: PlayerCharacter):
	if curse_key != "":
		Curses.status[curse_key] += 1

	for boon in boons:
		Boons.status[boon.key] += boon.value

func drop(player: PlayerCharacter):
	if curse_key != "":
		Curses.status[curse_key] -= 1

	for boon in boons:
		Boons.status[boon.key] -= boon.value

# Called when the node enters the scene tree for the first time.
func _ready():
	var description_text = ""
	for boon in boons:
		description_text += str(Boons.description[boon.key], ": ", boon.value, "\n")

	if curse_key != "":
		description_text += str("[color=#AA4444]", Curses.description[curse_key], "[/color]")
		
	description_label.text = description_text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_2d_body_entered(body):
	pass # Replace with function body.

func randomize(level: int):
	curse_key = Curses.status.keys().pick_random()
	var num_boons = min(3, randi_range(1, 1 + Main.level / 3))
