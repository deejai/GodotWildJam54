extends Node

class_name Item

@export var curse_key: String = ""
@export var boons: Array[Dictionary] = []

@onready var description_label: RichTextLabel = $Description

func pickup():
	if curse_key != "":
		Curses.status[curse_key] += 1

	for boon in boons:
		Boons.status[boon.key] += boon.value

func drop():
	if curse_key != "":
		Curses.status[curse_key] -= 1

	for boon in boons:
		Boons.status[boon.key] -= boon.value

# Called when the node enters the scene tree for the first time.
func _ready():
	var description_text = ""
	for boon in boons:
		var value_string = ": %.2f" % boon.value if boon.value is float else ": %d" % boon.value
		description_text += str("[color=#66AA44]", Boons.description[boon.key], value_string, "[/color]\n")

	if curse_key != "":
		description_text += str("[color=#AA4444]", Curses.description[curse_key], "[/color]")
		
	description_label.text = description_text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_2d_body_entered(body):
	if body is PlayerCharacter:
		pickup()

func _on_area_2d_body_exited(body):
	if body is PlayerCharacter:
		drop()

func randomize(level: int):
	curse_key = Curses.status.keys().pick_random()
	var num_boons = min(3, randi_range(1, 1 + Main.level / 3))
 
	var boon_choices = Boons.status.keys().duplicate()
	boon_choices.shuffle()

	for i in range(num_boons):
		var key = boon_choices.pop_front()
		boons.append({"key": key, "value": Boons.random_boon_value(key, level)})



