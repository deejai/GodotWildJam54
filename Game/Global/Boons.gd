extends Node

var status: Dictionary = {
	"rate_of_fire": 0,
	"bullet_damage": 0,
	"bullet_spread": 0,
	"lifesteal": 0,
	"speed": 0,
	"fireballs": 0,
}

var description: Dictionary = {
	"rate_of_fire": "Fire Rate",
	"bullet_damage": "Damage",
	"bullet_spread": "Spread",
	"lifesteal": "Life Steal",
	"speed": "Move Speed",
	"fireballs": "Fireballs",
}

func random_boon_value(key: String, level: int):
	if randf() > 0.9:
		level += randi_range(1, 2)

	match(key):
		"rate_of_fire":
			return randf_range(0.05 + 0.03 * level, 0.2 + 0.05 * level)

		"bullet_damage":
			return randf_range(2.0 + 1.0 * level, 5.0 + 2.0 * level)

		"bullet_spread":
			return randi_range(1, 1 + level / 3)

		"lifesteal":
			return randf_range(1.0 + 0.3 * level, 1.8 + 0.6 * level)

		"speed":
			return randf_range(0.05 + 0.03 * level, 0.2 + 0.05 * level)

		"fireballs":
			return randi_range(1, 1 + level / 2)

		_:
			assert(false)

	return false

func reset():
	for key in status:
		status[key] = 0
