extends Node

var banana_monster: PackedScene = load("res://Game/Characters/BananaMonster.tscn")

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
		spawn_timer = 5.0
		var new_monster = banana_monster.instantiate()
		new_monster.position = Main.floor_instance.boss.position + Vector2.ONE.rotated(randf() * 2 * PI) * randf_range(50.0, 60.0)
		new_monster.level = Main.level
		new_monster.is_summon = true
		Main.floor_instance.add_child(new_monster)
