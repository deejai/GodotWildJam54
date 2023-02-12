extends Node2D

var lifetime: float = 2.0
var direction: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += direction * 10.0
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
