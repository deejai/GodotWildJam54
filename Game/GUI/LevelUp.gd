extends CanvasLayer

var timer = 1.2

@onready var label: RichTextLabel = $LevelUp

# Called when the node enters the scene tree for the first time.
func _ready():
	label.modulate.a = 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(timer)
	timer -= delta
	label.position.y -= delta * 20.0
	label.modulate.a -= delta * .8
	if timer <= 0.0:
		queue_free()
