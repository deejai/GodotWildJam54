extends CanvasLayer

@onready var accept_button: Button = $AcceptButton
@onready var mainmenu: PackedScene = load("res://Game/Views/MainMenu.tscn")

const show_button_delay: float = 1.5
var show_button_timer: float = show_button_delay

# Called when the node enters the scene tree for the first time.
func _ready():
	accept_button.text = [
		"A single death is a tragedy; a million is a roguelike.",
		"Death should take me while I am in the mood.",
		"It’s better to burn out than to fade away.",
		"Death smiles at us all, all a man can do is smile back.",
		"Dying is a wild night and a new road.",
		"Cowards die many times; the valiant taste death but once.",
	].pick_random()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not visible:
		accept_button.modulate = Color(.8,.8,.8,0)
		show_button_timer = show_button_delay
	elif show_button_timer > 0.0:
		show_button_timer -= delta
	elif accept_button.modulate.a == 1.0:
		pass
	elif accept_button.modulate.a == 0.0:
		accept_button.modulate.a = 0.01
	else:
		accept_button.modulate.a = min(1.0, accept_button.modulate.a * 1.0 + (.45 * delta / 1.0))

func _on_accept_button_pressed():
	get_tree().change_scene_to_packed(mainmenu)
