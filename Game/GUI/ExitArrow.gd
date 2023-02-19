extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_instance_valid(Main.floor_instance.exit_instance):
		visible = true
		rotation = (Main.player.position).direction_to(Main.floor_instance.exit_instance.position).angle()
	else:
		visible = false
