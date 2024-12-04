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
