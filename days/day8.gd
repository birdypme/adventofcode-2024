extends "res://days/day.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.day_number = 8
    self.day_suffix = ''
    super._ready()
    var example_input = self.read_input('example')
    process_lines(clean_input(example_input))
    var data_input = self.read_input('data')
    process_lines(clean_input(data_input))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func clean_input(lines: PackedStringArray):
    var output = []
    for line in lines:
        if line:
            output.append(line)
    return PackedStringArray(output)


func process_lines(lines: PackedStringArray):
    var total = 0
    var total2 = 0
    var width = len(lines[0])
    var height = len(lines)
    var antennas = {}
    for j in range(height):
        var line = lines[j]
        for i in range(width):
            var cell = line[i]
            if cell == '.':
                continue
            if cell not in antennas:
                antennas[cell] = []
            antennas[cell].append(Vector2i(i, j))
            
    var antinodes = []
    var antinodes2 = []
    for j in range(height):
        var line = []
        var line2 = []
        for i in range(width):
            line.append('.')
            line2.append('.')
        antinodes.append(line)
        antinodes2.append(line2)

    for k in antennas:
        var a = antennas[k]
        #print(k, ': ', len(a), ' antennas')
        for i in range(len(a)):
            if antinodes2[a[i].y][a[i].x] != '#':
                total2 = total2 + 1
            antinodes2[a[i].y][a[i].x] = '#'
            for j in range(i+1, len(a)):
                var delta = a[j]-a[i]
                var x0 = a[i] - delta
                if x0.x >= 0 and x0.x < width and x0.y >= 0 and x0.y < height:
                    if antinodes[x0.y][x0.x] != '#':
                        total = total + 1
                    antinodes[x0.y][x0.x] = '#'
                var x1 = a[j] + delta
                if x1.x >= 0 and x1.x < width and x1.y >= 0 and x1.y < height:
                    if antinodes[x1.y][x1.x] != '#':
                        total = total + 1
                    antinodes[x1.y][x1.x] = '#'
                    
                while x0.x >= 0 and x0.x < width and x0.y >= 0 and x0.y < height:
                    if antinodes2[x0.y][x0.x] != '#':
                        total2 = total2 + 1
                    antinodes2[x0.y][x0.x] = '#'
                    x0 = x0 - delta
                while x1.x >= 0 and x1.x < width and x1.y >= 0 and x1.y < height:
                    if antinodes2[x1.y][x1.x] != '#':
                        total2 = total2 + 1
                    antinodes2[x1.y][x1.x] = '#'
                    x1 = x1 + delta
        
    print('total: ', total)
    print('total2: ', total2)
    
