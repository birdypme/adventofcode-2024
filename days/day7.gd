extends "res://days/day.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.day_number = 7
    self.day_suffix = ''
    super._ready()
    print('EXAMPLE')
    var input_lines = self.read_input('example')
    process_lines(input_lines)

    print('DATA')
    input_lines = self.read_input('data')
    process_lines(input_lines)

func tryoperators2(s, cc, v):
    if not cc:
        return s == v
    var c = cc[0]
    var a = s + c
    if a <= v and tryoperators2(a, cc.slice(1), v):
        return true

    var m = s * c
    if m <= v and tryoperators2(m, cc.slice(1), v):
        return true

    var t = int(str(s) + str(c))
    if t <= v and tryoperators2(t, cc.slice(1), v):
        return true
    return false


func tryoperators(s, cc, v):
    if not cc:
        return s == v
    var c = cc[0]
    var a = s + c
    if a <= v and tryoperators(a, cc.slice(1), v):
        return true

    var m = s * c
    if m <= v and tryoperators(m, cc.slice(1), v):
        return true

    return false


func process_lines(lines: PackedStringArray):
    var total = 0
    var total2 = 0
    for line in lines:
        if not line:
            continue
        var x = line.split(':')
        var v = int(x[0])
        x = x[1].split(' ')
        var components = []
        for c in x:
            if not c:
                continue
            components.append(int(c))
        var s = components[0]
        if tryoperators(s, components.slice(1), v):
            #print('found: ', v)
            total = total + v
        if tryoperators2(s, components.slice(1), v):
            total2 = total2 + v
    # star 1:
    # 880584941917 is too low
    # 882304362421 
    print('total: ', total)
    # star 2:
    # 145149066755184
    print('total2: ', total2)
