extends "res://days/day.gd"

@onready var data_lines = find_child('DataLines')
@onready var sorted_lines = find_child('SortedLines')
@onready var distances_lines = find_child('Distances')
@onready var result_text = find_child('Result')

func _ready():
    self.day_number = 1
    super._ready()
    
    var lines = self.read_input('data')
    var template_line = self.get_template('Line')
    var line_number = 1
    
    var items_left = []
    var items_right = []
    
    for line in lines:
        if not line:
            continue

        var line_control = template_line.duplicate()
        line_control.name = 'Line' + str(line_number)
        data_lines.add_child(line_control)
        line_control.owner = data_lines
        line_control.text = line
        
        var items = line.split('   ')
        var item_left = items[0]
        var item_right = items[1]
        items_left.append(int(item_left))
        items_right.append(int(item_right))
        
        line_number += 1
        
    var total = 0
    items_left.sort()
    items_right.sort()
    for i in range(len(items_left)):
        var item_left = items_left[i]
        var item_right = items_right[i]
        var distance = abs(item_right - item_left)
        
        var line_control = template_line.duplicate()
        line_control.name = 'Sorted' + str(i)
        sorted_lines.add_child(line_control)
        line_control.owner = data_lines
        line_control.text = '{0}   {1}'.format([item_left, item_right])

        line_control = template_line.duplicate()
        line_control.name = 'Dist' + str(i)
        distances_lines.add_child(line_control)
        line_control.owner = data_lines
        line_control.text = '{0}'.format([distance])

        total += distance
        
    result_text.text = str(total)

func _process(delta):
    super._process(delta)


func _on_copy_pressed() -> void:
    var current_clipboard = DisplayServer.clipboard_get()
    DisplayServer.clipboard_set(result_text.text)
