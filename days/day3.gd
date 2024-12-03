extends "res://days/day.gd"

var regex = RegEx.new()


func process_line(line: String):
    if not line:
        return 0
        
    var total = 0
    for result in regex.search_all(line):
        print(result.get_string())
        var a = int(result.get_string(1))
        var b = int(result.get_string(2))
        var m = a * b
        total += m
        print(str(a),' * ', str(b), ' = ', str(m))
    return total


func process_input(prefix: String='data', suffix: String=''):
    var lines = self.read_input(prefix, suffix)
    var line_number = 1
    var total = 0

    for line in lines:
        total += process_line(line)
    print(total)
    return total  

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.day_number = 3
    self.day_suffix = ''
    super._ready()
    regex.compile('mul\\((\\d\\d?\\d?),(\\d\\d?\\d?)\\)')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_run_pressed(prefix: String='data', suffix: String='') -> void:
    process_input(prefix, suffix)
