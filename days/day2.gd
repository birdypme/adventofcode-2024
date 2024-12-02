extends "res://days/day.gd"

@onready var data_lines = find_child('DataLines')
@onready var result_text = find_child('Result')

@export var wrong: Texture2D
@export var right: Texture2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.day_number = 2
    self.day_suffix = ''
    super._ready()

    var lines = self.read_input('data')
    var template_line = self.get_template('Line')
    var line_number = 1
    var total = 0
    
    for line in lines:
        if not line:
            continue
        var items = line.split(' ')
        var cells = [] as Array[int]
        for item in items:
            cells.append(int(item))
        var safe = is_safe(cells)
        
        var line_control = template_line.duplicate()
        line_control.name = 'Line' + str(line_number)
        data_lines.add_child(line_control)
        line_control.owner = data_lines
        line_control.get_child(0).text = line
        line_control.get_child(1).texture = right if safe else wrong
        if safe:
            total += 1
            
    result_text.text = str(total)


func is_safe(cells: Array[int]) -> bool:
    var prev = null
    var slope = cells[1] - cells[0]
    if slope == 0:
        return false
    slope = sign(slope)
    for cell in cells:
        if prev == null:
            prev = cell
            continue
        var diff = cell - prev
        if diff == 0:
            return false
        if sign(diff) != slope:
            return false
        if abs(diff) > 3:
            return false
        prev = cell
    return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func _on_copy_pressed() -> void:
    var current_clipboard = DisplayServer.clipboard_get()
    DisplayServer.clipboard_set(result_text.text)
