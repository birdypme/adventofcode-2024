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
    var total = 0

    total += process_line(''.join(lines))
    print(total)
    return total  

func escape_bbcode(text: String) -> String:
    return text.replace('[', '[lb]')


func process_line_2(line: String) -> int:
    if not line:
        return 0
        
    var length = len(line)
    var i = 0
    var mul_active = true
    var total = 0
    
    var debug_text = '[color=green]'
    
    while i < length:
        if line[i] not in ['d', 'm']:
            debug_text += escape_bbcode(line[i])
            i += 1
            continue

        var sub_line = line.substr(i)
        if sub_line.begins_with('mul('):
            i += 4
            if not mul_active:
                debug_text += '[color=lightgray]'
                debug_text += escape_bbcode(line.substr(i-4, 4))
                debug_text += '[/color]'
            else:
                var begin1 = i
                var end1 = begin1
                while line[end1].is_valid_int():
                    end1 += 1
                var has_comma = line[end1] == ','
                var begin2 = end1 + 1
                var end2 = begin2
                while line[end2].is_valid_int():
                    end2 += 1
                var has_closing = line[end2] == ')'
                if end1 > begin1 and end1 < begin1 + 4 and end2 > begin2 and end2 < begin2 + 4 and has_comma and has_closing:
                    var a = int(line.substr(begin1, end1-begin1))
                    var b = int(line.substr(begin2, end2-begin2))
                    var m = a * b
                    total += m
                    debug_text += '[color=white]'
                    debug_text += escape_bbcode(line.substr(begin1-4, end2+1-begin1+4))
                    debug_text += '[/color]'
                    i = end2+1
                else:
                    debug_text += '[color=darkred]'
                    debug_text += escape_bbcode(line.substr(begin1-4, 4))
                    debug_text += '[/color]'
        elif sub_line.begins_with('do()'):
            mul_active = true
            debug_text += '[/color]'
            debug_text += '[color=lightgreen]'
            debug_text += escape_bbcode(line.substr(i, 4))
            debug_text += '[/color]'
            debug_text += '[color=green]'
            i += 4
        elif sub_line.begins_with('don\'t()'):
            mul_active = false
            debug_text += '[/color]'
            debug_text += '[color=red]'
            debug_text += escape_bbcode(line.substr(i, 7))
            debug_text += '[/color]'
            debug_text += '[color=darkred]'
            i += 7
        else:
            debug_text += escape_bbcode(line[i])
            i += 1

    debug_text += '[/color]'
    find_child('Debug').text = debug_text
    return total


func process_input_2(prefix: String='data', suffix: String=''):
    var lines = self.read_input(prefix, suffix)
    var total = 0

    total += process_line_2(''.join(lines))
    print(total)
    # 107307267 is too high
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

func _on_run_2_pressed(prefix: String='data', suffix: String='') -> void:
    process_input_2(prefix, suffix)
