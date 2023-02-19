extends Node

var berry_fly_a: PackedScene = load("res://Game/Characters/BerryFlyA.tscn")
var berry_fly_b: PackedScene = load("res://Game/Characters/BerryFlyB.tscn")

@onready var hp_bar = $CanvasLayer/HPBar

var spawn_timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	hp_bar.value = Main.floor_instance.boss.hp
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = 1.4
		var new_monster = [berry_fly_a, berry_fly_b].pick_random().instantiate()
		var shoot_direction = Main.floor_instance.boss.position.direction_to(Main.player.position).rotated(randf_range(-1.0,1.0) * PI/12)
		new_monster.velocity = shoot_direction * 50.0
		new_monster.position = Main.floor_instance.boss.position + shoot_direction * randf_range(25.0, 30.0)
		new_monster.level = Main.level
		new_monster.is_summon = true
		new_monster.expires = true
		new_monster.time_remaining = 0.7
		Main.floor_instance.add_child(new_monster)
