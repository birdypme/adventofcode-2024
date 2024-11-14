extends "res://days/day.gd"

@onready var content = find_child('Content')

func _ready():
    self.day_number = 1
    super._ready()
    
    var lines = self.read_input()
    var template_line = self.get_template('Line')
    var line_number = 1
    for line in lines:
        var line_control = template_line.duplicate()
        line_control.name = 'Line' + str(line_number)
        content.add_child(line_control)
        line_control.owner = content
        line_control.text = line
        line_number += 1

func _process(delta):
    super._process(delta)
