extends "res://days/day.gd"

@export var search_string = "XMAS"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.day_number = 4
    self.day_suffix = ''
    super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func check_pattern(lines: PackedStringArray, width: int, height: int, x: int, y: int, dx: int, dy: int) -> int:
    var l = len(search_string)
    for i in range(l):
        if x < 0 or x >= width:
            return 0
        if y < 0 or y >= height:
            return 0
        if lines[y][x] != search_string[i]:
            return 0
        x += dx
        y += dy
    return 1

func _on_run_pressed(prefix: String='data', suffix: String=''):
    var lines = self.read_input(prefix, suffix)
    var height = len(lines)
    var width = len(lines[0])
    var total = 0
    for y in range(height):
        for x in range(width):
            total += check_pattern(lines, width, height, x, y, -1, -1)
            total += check_pattern(lines, width, height, x, y, -1, 0)
            total += check_pattern(lines, width, height, x, y, -1, +1)
            total += check_pattern(lines, width, height, x, y, 0, -1)
            total += check_pattern(lines, width, height, x, y, 0, +1)
            total += check_pattern(lines, width, height, x, y, +1, -1)
            total += check_pattern(lines, width, height, x, y, +1, 0)
            total += check_pattern(lines, width, height, x, y, +1, +1)
    print(total)

func _on_run_2_pressed(prefix: String='data', suffix: String=''):
    var lines = self.read_input(prefix, suffix)
    var height = len(lines)
    var width = len(lines[0])
    var total = 0
    for y in range(1, height-1):
        for x in range(1, width-1):
            total += check_x(lines, width, height, x, y)
    print(total)


func check_x(lines: PackedStringArray, width: int, height: int, x: int, y: int) -> int:
    if lines[y][x] != 'A':
        return 0
    var is_mas = lines[y-1][x-1] == 'M' and lines[y+1][x+1] == 'S'
    var is_sam = lines[y-1][x-1] == 'S' and lines[y+1][x+1] == 'M'
    if not is_mas and not is_sam:
        return 0
    is_mas = lines[y+1][x-1] == 'M' and lines[y-1][x+1] == 'S'
    is_sam = lines[y+1][x-1] == 'S' and lines[y-1][x+1] == 'M'
    if not is_mas and not is_sam:
        return 0
    return 1        
