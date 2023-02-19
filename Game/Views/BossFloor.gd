extends Node2D

class_name BossFloor

@export var track: MusicServer.Track
@export var boss_scene: PackedScene

var exit_scene = load("res://Game/Objects/DungeonExit.tscn")

@onready var boss_spawn_position: Vector2 = $BossSpawnPoint.position
@onready var exit_position: Vector2 = $ExitPoint.position

var boss

var boss_defeated: bool = false
var next_unlocked: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Main.floor_instance = self
	add_child(Main.player)
	Main.player.position = Vector2.ZERO
	Main.music.set_track(track)
	Main.floor_timer_begin(60.0)
	boss = boss_scene.instantiate()
	boss.position = boss_spawn_position
	add_child(boss)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if boss_defeated and !next_unlocked:
		Main.floor_timer_enabled = false
		Main.music.stop()
		Main.victory_sound.play()
		var exit = exit_scene.instantiate()
		exit.position = exit_position
		Main.floor_instance.add_child(exit)
		next_unlocked = true
