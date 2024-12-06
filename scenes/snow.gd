extends Node2D

@onready var generators = find_child('ParticleGenerators')
var total_time = 0
@export var particle_emitters = 10

var screen_size = 1080

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var generator = find_child('GPUParticles2D')
    for i in range(particle_emitters-1):
        var clone = generator.duplicate()
        generators.add_child(clone)
        clone.owner = generators
        clone.position = Vector2((i+1.0) * screen_size / particle_emitters, clone.position.y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    total_time += delta
    var bleeding = 50
    for generator in generators.get_children():
        generator.position = Vector2(randf_range(-bleeding, screen_size+bleeding), generator.position.y)
