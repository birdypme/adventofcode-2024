extends "res://days/day.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.day_number = 9
    super._ready()
    launch('example')
    launch('data')


func to_sectors(line: String) -> Array:
    var x = 0
    var isdot = false
    var content = []
    for c in line:
        if isdot:
            var a = []
            a.resize(int(c))
            a.fill('.')
            content.append_array(a)
        else:
            var a = []
            a.resize(int(c))
            a.fill(x)
            content.append_array(a)
            x += 1
        isdot = not isdot
    return content


func optimize(content: Array) -> Array:
    var optimized = []
    optimized.resize(len(content))
    optimized.fill('.')
    var i = 0
    var j = len(content) - 1
    while j >= i and content[j] is String and content[j] == '.':
        j -= 1
    while i <= j:
        if content[i] is String and content[i] == '.':
            optimized[i] = content[j]
            j -= 1
            while j >= i and content[j] is String and content[j] == '.':
                j -= 1
        else:
            optimized[i] = content[i]
        i += 1
    return optimized

func checksum(optimized: Array) -> int:
    var total = 0
    var pos = 0
    for c in optimized:
        if c is String and c == '.':
            break
        var v = c * pos
        total += v
        pos += 1
    return total


func launch(prefix: String):
    var lines = self.read_input(prefix)
    var line = lines[0]
    print(line.substr(0, 128))
    var content = to_sectors(line)
    print(content.slice(0, 128))
    var optimized = optimize(content)
    print(optimized.slice(0, 128))
  
    var total = checksum(optimized)
    # 88881734731: too low
    print(total)
