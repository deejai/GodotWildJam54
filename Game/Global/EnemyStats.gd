extends Node

enum Type {BANANA_BAT, BLUEBERRY, BLUEBERRY_FLY_A, BLUEBERRY_FLY_B, ORANGE, BANANA_WALKER, TOMATO, CHERRY, BOSS1, BOSS2, BOSS3, NONE}

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
	enemy.stat_speed_mult = 1.0 + .04 * (enemy.level-1)

	match(enemy.type):
		Type.BANANA_BAT:
			enemy.stat_melee_damage *= 1.20
			enemy.stat_speed_mult *= 1.4
		Type.BLUEBERRY:
			enemy.stat_damage_received_mult *= 1.3
		Type.BLUEBERRY_FLY_A:
			enemy.stat_melee_damage *= 0.3
			enemy.stat_speed_mult *= 3.0
			enemy.stat_bullet_damage_mult = 0.15
			enemy.stat_damage_received_mult *= 3.0
			enemy.stat_xp_reward *= .34
		Type.BLUEBERRY_FLY_B:
			enemy.stat_melee_damage *= 0.3
			enemy.stat_speed_mult *= 3.0
			enemy.stat_bullet_damage_mult = 0.15
			enemy.stat_damage_received_mult *= 3.0
			enemy.stat_xp_reward *= .34
		Type.TOMATO:
			enemy.stat_damage_received_mult *= 0.5
			enemy.stat_speed_mult *= 0.5
			enemy.stat_melee_damage *= 2.0
		Type.BOSS1:
			enemy.stat_bullet_damage_mult
			enemy.stat_damage_received_mult = 0.17
			enemy.stat_melee_damage = 30
			enemy.stat_xp_reward = 1000
			enemy.stat_speed_mult = 1.0
		Type.BOSS2:
			enemy.stat_bullet_damage_mult
			enemy.stat_damage_received_mult = 0.12
			enemy.stat_melee_damage = 35
			enemy.stat_xp_reward = 1000
			enemy.stat_speed_mult = 1.1
		Type.BOSS3:
			enemy.stat_bullet_damage_mult
			enemy.stat_damage_received_mult = 0.07
			enemy.stat_melee_damage = 40
			enemy.stat_xp_reward = 1000
			enemy.stat_speed_mult = 1.2
