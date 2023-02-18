extends Node2D

@onready var frect: ColorRect = $FRect

# Called when the node enters the scene tree for the first time.
func _ready():
	frect.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if frect.visible and Input.is_action_just_pressed("Descend"):
		Main.descend()

func _on_area_2d_body_entered(body):
	if body is PlayerCharacter:
		frect.visible = true


func _on_area_2d_body_exited(body):
	if body is PlayerCharacter:
		frect.visible = false
