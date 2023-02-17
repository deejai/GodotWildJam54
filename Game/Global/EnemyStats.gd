extends Node

enum Type {BANANA_BAT, BLUEBERRY, ORANGE, BANANA_WALKER, TOMATO, CHERRY, NONE}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

static func setup_stats(enemy: EnemyCharacter):
	enemy.stat_bullet_damage_mult = 1.0 + 0.05 * (enemy.level-1)
	enemy.stat_damage_received_mult = 1.0 * pow(0.97,  (enemy.level-1))
	enemy.stat_melee_damage = 15.0 + 3.0 * (enemy.level-1)
	enemy.stat_xp_reward = 20.0 + 8.0 * (enemy.level-1)

	match(enemy.type):
		Type.BANANA_BAT:
			enemy.stat_melee_damage *= 1.20
