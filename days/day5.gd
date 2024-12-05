extends "res://days/day.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.day_number = 5
    self.day_suffix = ''
    super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func parse_input(lines: PackedStringArray):
    var dependencies = {}
    var printable = []
    var i = 0
    while lines[i]:
        var d = lines[i].split('|')
        if d[1] not in dependencies:
            dependencies[d[1]] = []
        dependencies[d[1]].append(d[0])
        i += 1
    i += 1
    while i < len(lines):
        var p = lines[i].split(',')
        printable.append(p)
        i += 1
    return [dependencies, printable]

func print_page(printable, printed, p, dependencies):
    if p in printed:
        return
    if p not in printable:
        return
    var slocal = [p]
    if p in dependencies:
        for x in dependencies[p]:
            print_page(printable, printed, x, dependencies)
    slocal.reverse()
    printed.append_array(slocal)

func process(lines: PackedStringArray):
    var parsed_input = parse_input(lines)
    var dependencies = parsed_input[0]
    var printables = parsed_input[1]
    var total = 0
    var adding = []
    for printable in printables:
        var printed = []
        for p in printable:
            print_page(printable, printed, p, dependencies)
        # print(printable, ' vs ', printed)
        if str(printable) == str(printed):
            var item = int(printable[int((len(printable))/2)])
            adding.append(item)
            total += item
    print(' + '.join(adding), ' = ', total)

func _on_run_pressed(prefix: String='data', suffix: String=''):
    var lines = self.read_input(prefix, suffix)
    process(lines)


func process2(lines: PackedStringArray):
    var parsed_input = parse_input(lines)
    var dependencies = parsed_input[0]
    var printables = parsed_input[1]
    var total = 0
    var adding = []
    for printable in printables:
        var printed = []
        for p in printable:
            print_page(printable, printed, p, dependencies)
        # print(printable, ' vs ', printed)
        if str(printable) != str(printed):
            var item = int(printed[int((len(printed))/2)])
            adding.append(item)
            total += item
    print(' + '.join(adding), ' = ', total)


func _on_run_2_pressed(prefix: String='data', suffix: String=''):
    var lines = self.read_input(prefix, suffix)
    process2(lines)
    
