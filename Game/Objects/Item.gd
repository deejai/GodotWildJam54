extends Node2D

class_name Item

@export var curse_key: String = ""
@export var boons: Array[Dictionary] = []

@onready var description_label: RichTextLabel = $Description
@onready var qe_rect: ColorRect = $QERect

@export var pickup_sound: AudioStreamWAV

var equipped: bool = false

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
	qe_rect.visible = false
	var description_text = ""
	for boon in boons:
		var value_string = ": %.2f" % boon.value if boon.value is float else ": %d" % boon.value
		description_text += str("[color=#443344]", Boons.description[boon.key], "[b]", value_string, "[/b][/color]\n")

	if curse_key != "":
		description_text += str("[color=#AA2222]", Curses.description[curse_key], "[/color]")
		
	description_label.text = description_text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if qe_rect.visible:
		if Input.is_action_just_pressed("Equip Q"):
			if Main.player.slot_e != null and Main.player.slot_e.curse_key == curse_key:
				Main.player.gui.show_cant_equip()
			else:
				if Main.player.slot_q != null:
					Main.player.slot_q.drop()
				pickup()
				Main.player.slot_q = self
				get_parent().remove_child(self)
				Main.player.gui.qslot_bg.add_child(self)
				position = Vector2(50, 50)
				qe_rect.visible = false
				Main.player.gui.qrect.visible = false
				Main.player.gui.erect.visible = false
				equipped = true
				z_index = 0
				Main.play_random_sound([pickup_sound], global_position)
		elif Input.is_action_just_pressed("Equip E"):
			if Main.player.slot_q != null and Main.player.slot_q.curse_key == curse_key:
				Main.player.gui.show_cant_equip()
			else:
				if Main.player.slot_e != null:
					Main.player.slot_e.drop()
				pickup()
				Main.player.slot_e = self
				get_parent().remove_child(self)
				Main.player.gui.eslot_bg.add_child(self)
				position = Vector2(50, 50)
				qe_rect.visible = false
				Main.player.gui.qrect.visible = false
				Main.player.gui.erect.visible = false
				equipped = true
				z_index = 0
				Main.play_random_sound([pickup_sound], global_position)

func _on_area_2d_body_entered(body):
	if not equipped:
		if body is PlayerCharacter:
			qe_rect.visible = true
			Main.player.gui.qrect.visible = true
			Main.player.gui.erect.visible = true

func _on_area_2d_body_exited(body):
	if not equipped:
		if body is PlayerCharacter:
			qe_rect.visible = false
			Main.player.gui.qrect.visible = false
			Main.player.gui.erect.visible = false

func randomize(level: int):
	curse_key = Curses.status.keys().pick_random()
	var num_boons = min(3, randi_range(1, 2 + Main.level / 3))
 
	var boon_choices = Boons.status.keys().duplicate()
	boon_choices.shuffle()

	for i in range(num_boons):
		var key = boon_choices.pop_front()
		boons.append({"key": key, "value": Boons.random_boon_value(key, level)})


func _on_area_2d_mouse_entered():
	pass
