extends "res://days/day.gd"

@onready var data_lines = find_child('DataLines')
@onready var result_text = find_child('Result')

func _ready():
    self.day_number = 1
    self.day_suffix = 'bis'
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
    var i = 0
    var j = 0
    var prev_left = null
    var count_left = 0
    items_left.append(null)
    while i < len(items_left) and j < len(items_right):
        var item_left = items_left[i]
        if prev_left != null and item_left != null and prev_left == item_left:
            count_left += 1
            i += 1
            continue

        if prev_left != null:
            while j < len(items_right) and items_right[j] < prev_left:
                j += 1
            var count_right = 0
            while j < len(items_right) and items_right[j] == prev_left:
                count_right += 1
                j += 1
            total += prev_left * count_left * count_right

        prev_left = item_left
        count_left = 1
        i += 1
        continue

    result_text.text = str(total)

func _process(delta):
    super._process(delta)


func _on_copy_pressed() -> void:
    var current_clipboard = DisplayServer.clipboard_get()
    DisplayServer.clipboard_set(result_text.text)
