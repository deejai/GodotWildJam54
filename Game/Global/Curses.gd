extends Node

var status: Dictionary = {
	"cursed_gui": 0,
	"reverse_controls": 0,
	"random_teleport": 0,
	"hp_drain": 0,
}

var description: Dictionary = {
	"cursed_gui": "You might feel crazy",
	"reverse_controls": "You might find yourself disoriented",
	"random_teleport": "You might become unstable",
	"hp_drain": "You might find that it drains you",
}

var deals_with_the_devil: int = 0

func reset():
	for key in status:
		status[key] = 0

	deals_with_the_devil = 0
