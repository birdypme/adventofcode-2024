extends "res://days/day.gd"

@onready var data_lines = find_child('DataLines')
@onready var result_text = find_child('Result')
@onready var result_bis_text = find_child('ResultBis')

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
    var total_bis = 0
    
    for line in lines:
        if not line:
            continue
        var items = line.split(' ')
        var cells = [] as Array[int]
        for item in items:
            cells.append(int(item))
        var safe = is_safe(cells)
        var safe_bis = is_safe_bis(cells)
        
        var line_control = template_line.duplicate()
        line_control.name = 'Line' + str(line_number)
        data_lines.add_child(line_control)
        line_control.owner = data_lines
        line_control.get_child(0).text = line
        line_control.get_child(1).texture = right if safe else wrong
        line_control.get_child(2).texture = right if safe_bis else wrong
        if safe:
            total += 1
        if safe_bis:
            total_bis += 1
        if safe and not safe_bis:
            push_warning(line)

            
    result_text.text = str(total)
    result_bis_text.text = str(total_bis)


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

func is_safe_bis(cells: Array[int]) -> bool:
    if is_safe_bis_sloped(cells.slice(0), 1, 1) <= 1:
        return true
    if is_safe_bis_sloped(cells.slice(0), 1, -1) <= 1:
        return true
    return false

func branch(cells: Array[int], loc: int, max_errors: int, slope: int) -> int:
    var last_errors = 0

    for pivot in [loc-1, loc]:
        var branch_cells = cells.slice(0, pivot) as Array[int]
        branch_cells.append_array(cells.slice(pivot+1))
        last_errors = is_safe_bis_sloped(branch_cells, max_errors, slope)
        if last_errors <= max_errors:
            return last_errors
           
    return last_errors

func is_safe_bis_sloped(cells: Array[int], max_errors: int, slope: int) -> int:
    var errors = 0
    var prev = null
    #if cells[0] == 65 and cells[1] == 64:
        #print('this is here')
    for i in range(len(cells)):
        var cell = cells[i]
        if prev == null:
            prev = cell
            continue
        var diff = cell - prev
        if diff == 0 or sign(diff) != slope or abs(diff) > 3:
            errors += 1
            if errors <= max_errors:
                return errors + branch(cells, i, max_errors-errors, slope);
            return errors
        prev = cell
    return errors
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func _on_copy_pressed() -> void:
    var current_clipboard = DisplayServer.clipboard_get()
    DisplayServer.clipboard_set(result_text.text)


func _on_copy_bis_pressed() -> void:
    var current_clipboard = DisplayServer.clipboard_get()
    DisplayServer.clipboard_set(result_bis_text.text)
