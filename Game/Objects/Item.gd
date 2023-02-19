extends Node2D

class_name Item

@export var curse_key: String = ""
@export var boons: Array[Dictionary] = []

@onready var description_bg: TextureRect = $DescriptionBG
@onready var description_label: RichTextLabel = $Description
@onready var qe_rect: ColorRect = $QERect
@onready var area2d: Area2D = $Area2D
@onready var collision_rect: RectangleShape2D = $Area2D/CollisionShape2D.shape

@export var pickup_sound: AudioStreamWAV
@export var drop_sound: AudioStreamWAV

var equipped: bool = false

var image: TextureRect

func pickup():
	if curse_key != "":
		Curses.status[curse_key] += 1

	for boon in boons:
		Boons.status[boon.key] += boon.value

func drop():
	if Main.player.slot_q == self:
		Main.player.slot_q = null
	elif Main.player.slot_e == self:
		Main.player.slot_e = null
	else:
		assert(false)

	if curse_key != "":
		Curses.status[curse_key] -= 1

	for boon in boons:
		Boons.status[boon.key] -= boon.value

	get_parent().remove_child(self)
	Main.floor_instance.add_child(self)
	position = Main.player.position
	qe_rect.visible = false
	Main.player.gui.qrect.visible = false
	Main.player.gui.erect.visible = false
	equipped = false
	z_index = -5
	scale = Vector2.ONE
	Main.play_random_sound([drop_sound], global_position)

# Called when the node enters the scene tree for the first time.
func _ready():
	description_label.visible = false
	description_bg.visible = false
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
	if not equipped:
		image.scale = Vector2.ONE * (.95 + .1 * absf((500 - Time.get_ticks_msec() % 1000) / 1000.0))

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
	
	match(curse_key):
		"cursed_gui":
			image = $CrazyCurseImage
		"reverse_controls":
			image = $DisorientCurseImage
		"random_teleport":
			image = $UnstableCurseImage
		"hp_drain":
			image = $DrainCurseImage
		_:
			assert(false)
 
	image.visible = true

	var boon_choices = Boons.status.keys().duplicate()
	boon_choices.shuffle()

	for i in range(num_boons):
		var key = boon_choices.pop_front()
		boons.append({"key": key, "value": Boons.random_boon_value(key, level)})


func _on_area_2d_mouse_entered():
	image.visible = false
	description_label.visible = true
	description_bg.visible = true
	Main.player.gui.howtodrop.visible = equipped


func _on_area_2d_mouse_exited():
	image.visible = true
	description_label.visible = false
	description_bg.visible = false
	Main.player.gui.howtodrop.visible = false


func _on_area_2d_input_event(viewport, event, shape_idx):
	if equipped and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		drop()
