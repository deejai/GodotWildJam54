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
		
	if Main.floor_timer_enabled and Main.floor_timer <= 30.0:
		scale = Vector2.ONE * (.85 + .3 * absf((200 - Time.get_ticks_msec() % 400) / 400.0))
	else:
		scale = Vector2.ONE
