extends CanvasLayer

@onready var hp_bar: TextureProgressBar = $HPBar
@onready var xp_bar: TextureProgressBar = $XPBar
@onready var cursed_text_gui: RichTextLabel = $CursedBars
@onready var cursed_gui_image: TextureRect = $CursedGUIImage
@onready var stats: RichTextLabel = $Stats
@onready var show_stats: RichTextLabel = $ShowStats
@onready var timer_label: RichTextLabel = $TimerLabel

@onready var transition_layer = $TransitionLayer
@onready var transition_layer_sprite = $TransitionLayer/AnimatedSprite2D

@onready var qrect: ColorRect = $QRect
@onready var erect: ColorRect = $ERect

@onready var howtodrop: Label = $HowToDrop

@onready var qslot_bg: TextureRect = $Items/QSlotBG
@onready var eslot_bg: TextureRect = $Items/ESlotBG

var level_up_scene: PackedScene = load("res://Game/GUI/LevelUp.tscn")
var cant_equip_scene: PackedScene = load("res://Game/GUI/CantEquipSameCurse.tscn")

const cursed_gui_string: String = "All work and no play makes Jack a dull boy."

# Called when the node enters the scene tree for the first time.
func _ready():
	stats.visible = false
	qrect.visible = false
	erect.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Main.floor_timer_enabled:
		var minutes: int = floori(Main.floor_timer / 60.0)
		var seconds: int = floori(Main.floor_timer) % 60
		var decimal: int = ceili(Main.floor_timer * 100) % 100
		timer_label.text = "[color=#AA2222]%02d:%02d.%02d[/color]" % [minutes, seconds, decimal]

#	if transition_layer.visible:
#		transition_layer_sprite.modulate.a = max(0.0, transition_layer_sprite.modulate.a - .5 * delta)
#		if transition_layer_sprite.modulate.a == 0.0:
#			transition_layer.visible = false

	if Input.is_action_just_pressed("Show Stats"):
		stats.visible = !stats.visible
		show_stats.visible = !show_stats.visible

	if stats.visible:
		var stat_string = ""
		stat_string += str("Floor: ", Main.level, "\n")
		stat_string += str("HP: ", "%.2f" % Main.player.hp, " / ", 100, "\n")
		stat_string += str("Total XP: ", Main.player.xp, "\n")
		stat_string += str("XP to Next: ", Main.player.xp_to_next, "\n")
		stat_string += str("bullet_spread: ", Main.player.calc_bullet_spread(), "\n")
		stat_string += str("damage_received_mult: ", "%.2f" % (Main.player.stat_damage_received_mult + .3 * Curses.deals_with_the_devil), "\n")
		stat_string += str("speed_mult: ", "%.2f" % Main.player.stat_speed_mult, "\n")
		stat_string += str("rof_mult: ", "%.2f" % Main.player.stat_rof_mult, "\n")
		stat_string += str("bullet_damage: ", "%.2f" % Main.player.calc_bullet_damage(), "\n")
		stat_string += str("lifesteal: ", "%.2f" % Main.player.calc_lifesteal(), "\n")
		stat_string += str("fireballs: ", Main.player.calc_fireballs(), "\n")
		stat_string += str("deals with the devil: ", Curses.deals_with_the_devil, "\n")
		if Main.player.can_melee:
			stat_string += str("melee_damage: ", Main.player.stat_melee_damage, "\n")
			stat_string += str("melee_cd: ", Main.player.stat_melee_cd, "\n")
		stat_string += str("Curses: ")
		for key in Curses.status:
			if Curses.status[key] > 0:
				stat_string += str(" ", key)
		stat_string += "\n"

		stats.text = stat_string

	if Curses.status["cursed_gui"] > 0:
		hp_bar.visible = false
		xp_bar.visible = false
		cursed_text_gui.visible = true
		cursed_gui_image.visible = true

		cursed_text_gui.text = ""
		var hp_string = get_progress_text(cursed_gui_string, "#AA4444", Main.player.hp / 100.0)
		var xp_string = get_progress_text(cursed_gui_string, "#ADAA11", Main.player.xp_progress)
		for i in range(6):
			cursed_text_gui.text += str(xp_string, "\n")
		for i in range(14):
			cursed_text_gui.text += str(hp_string, "\n")
	else:
		hp_bar.value = 100.0 * Main.player.hp / 100.0
		xp_bar.value = 100.0 * Main.player.xp_progress
		cursed_text_gui.visible = false
		cursed_gui_image.visible = false
		hp_bar.visible = true
		xp_bar.visible = true

func get_progress_text(string, color_string, progress):
	var split_index = ceili(len(cursed_gui_string) * progress)
	var progress_text: String = str("[color=", color_string ,"]", cursed_gui_string.substr(0, split_index), "[/color]", cursed_gui_string.substr(split_index))
	return progress_text

func fade_transition():
	transition_layer.visible = true
	transition_layer_sprite.play()
	transition_layer_sprite.modulate.a = 1.0

func show_level_up():
	var instance = level_up_scene.instantiate()
	add_child(instance)

func show_cant_equip():
	var instance = cant_equip_scene.instantiate()
	add_child(instance)


func _on_animated_sprite_2d_animation_looped():
	transition_layer_sprite.stop()
	transition_layer.visible = false
