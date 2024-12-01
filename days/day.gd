extends Node2D

@export var day_number: int = 0
@export var day_suffix: String = ''
@onready var templates = find_child('Templates')

func _ready():
    var day_title = 'Day {day_number} {day_suffix}'.format({'day_number': str(day_number), 'day_suffix': str(day_suffix)})
    (self.find_child('DayTitle') as RichTextLabel).text = day_title

func _process(delta):
    pass

func _on_home_pressed() -> void:
    get_tree().change_scene_to_file('res://scenes/main.tscn')

func read_input(prefix: String='data', suffix: String='') -> PackedStringArray:
    return AdventParser.read_input(self.day_number, prefix, suffix)

func get_template(name: String) -> Node:
    return templates.find_child(name)
