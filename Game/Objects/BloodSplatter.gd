extends Node2D

@onready var emitter: GPUParticles2D = $GPUParticles2D

# Called when the node enters the scene tree for the first time.
func _ready():
	emitter.emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if emitter.emitting == false:
		queue_free()
