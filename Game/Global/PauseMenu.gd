extends CanvasLayer

var main_menu_scene: PackedScene = load("res://Game/Views/MainMenu.tscn")

@onready var resume_button: Button = $Resume
@onready var quit_button: Button = $Quit
@onready var confirm_quit_modal: ReferenceRect = $ConfirmQuitModal
@onready var confirm_quit: Button = $ConfirmQuitModal/ConfirmQuit
@onready var dont_quit: Button = $ConfirmQuitModal/DontQuit

@onready var hover_sound: AudioStreamPlayer = $HoverSound
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var quit_sound: AudioStreamPlayer = $QuitSound

# Called when the node enters the scene tree for the first time.
func _ready():
	confirm_quit_modal.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_resume_pressed():
	Main.set_pause(false)

func _on_quit_pressed():
	resume_button.disabled = true
	quit_button.disabled = true
	confirm_quit_modal.visible = true
	click_sound.play()

func _on_confirm_quit_pressed():
	Main.paused = false
	visible = false
	resume_button.disabled = false
	quit_button.disabled = false
	confirm_quit_modal.visible = false
	quit_sound.play()
	get_tree().paused = false
	get_tree().change_scene_to_packed(main_menu_scene)

func _on_dont_quit_pressed():
	resume_button.disabled = false
	quit_button.disabled = false
	confirm_quit_modal.visible = false
	click_sound.play()

func ui_hover():
	hover_sound.play()


func ui_click():
	click_sound.play()
