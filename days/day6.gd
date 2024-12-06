extends "res://days/day.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.day_number = 6
    self.day_suffix = ''
    super._ready()
    reached_destination = false
    marked_cells = 0
    found_loops = 0
    play_button.button_pressed = running
    current_cell = map.local_to_map(guard.position)
    guard.position = map.map_to_local(current_cell)
    direction = Vector2i.UP
    target_cell = current_cell + direction
    target.position = map.map_to_local(target_cell)
    mark_current()
    _on_zoom_pressed()


@onready var map = find_child('TileMap') as TileMap
@onready var guard = find_child('Guard') as Node2D
@onready var target = find_child('Target') as Node2D
@onready var loop_sources = find_child('LoopSources') as Node2D
@onready var play_button = find_child('Play') as CheckButton
@onready var paths = find_child('Paths') as Node2D
@onready var coordinates = find_child('Coordinates') as RichTextLabel
@onready var coordinates_box = find_child('CoordinatesBox') as Node2D
@export var running: bool = false:
    get:
        return running
    set(value):
        if running != value:
            running = value
        if play_button != null and play_button.button_pressed != running:
            play_button.button_pressed = running
        
@export var zoom_level: float = 0.1
var reached_destination = false

var total_time = 0
var blink_time = 0
var blink2_time = 0
const BLINK_PERIOD = 0.5
const BLINK2_PERIOD = 0.3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    total_time += delta
    if map.scale.x > zoom_level:
        var delta_zoom = map.scale.x * delta
        if map.scale.x - delta_zoom < zoom_level:
            map.scale = Vector2(zoom_level, zoom_level)
        else:
            map.scale -= Vector2(delta_zoom, delta_zoom)
    elif map.scale.x < zoom_level:
        var delta_zoom = map.scale.x * delta
        if map.scale.x + delta_zoom > zoom_level:
            map.scale = Vector2(zoom_level, zoom_level)
        else:
            map.scale += Vector2(delta_zoom, delta_zoom)
    if running:
        move_guard(delta)
    blink_time -= delta
    if blink_time < delta:
        blink_time += BLINK_PERIOD
        find_child('BlinkDisc').visible = not find_child('BlinkDisc').visible
    blink2_time -= delta
    if blink2_time < delta:
        blink2_time += BLINK2_PERIOD
        for child in find_children('BlinkDisc'):
            child.visible = not child.visible

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        var mouse_event_motion = event as InputEventMouseMotion
        var p = mouse_event_motion.global_position
        var l = map.to_local(p)
        var cell = map.local_to_map(l)
        #if coordinates == null:
            #return
        coordinates.text = str(cell)
        coordinates_box.position = map.map_to_local(cell)
        coordinates_box.visible = true

var current_cell = Vector2i.ZERO
var target_cell = Vector2i.ZERO
var loop_source_items = []
var last_cells = []
var direction = Vector2i.UP
@onready var guard_speed_control = find_child('GuardSpeed') as SpinBox
@export var guard_speed: float = 10.0:  # in tile/s
    get:
        if guard_speed_control != null:
            return guard_speed_control.value
        return guard_speed
    set(value):
        if guard_speed_control != null:
            guard_speed_control.value = value
        guard_speed_control = value
        
func turn_right(d):
    if d == Vector2i.UP:
        return Vector2i.RIGHT
    if d == Vector2i.RIGHT:
        return Vector2i.DOWN
    if d == Vector2i.DOWN:
        return Vector2i.LEFT
    if d == Vector2i.LEFT:
        return Vector2i.UP
    push_error('Unknon direction to turn right: ', d)

func is_aligned(d, a, b):
    var d1 = b - a
    if d.x == 0:
        return d1.x==0 and sign(d1.y) == sign(d.y)
    elif d.y == 0:
        return d1.y == 0 and sign(d1.x) == sign(d.x)
    push_error('Unknown direction to align: ', d)

var marked_cells = 0
var found_loops = 0
func mark_current():
    var source = map.get_cell_source_id(0, current_cell)
    if source == 0:
        map.set_cell(0, current_cell, 2, Vector2i.ZERO)
        marked_cells += 1

    if current_cell == Vector2i(52, 80):
        print('DEBUG')

    var right = turn_right(direction)
    for i in range(len(loop_source_items)):
        var loop_source_item = loop_source_items[i]
        var required_direction = loop_source_item[0]
        if required_direction != right:
            continue
        var loop_source_cell = loop_source_item[1]
        if not is_aligned(required_direction, current_cell, loop_source_cell):
            continue
            
        var cell = current_cell
        var walls = 0
        while cell != loop_source_cell:
            if map.get_cell_source_id(0, cell) == 1:
                walls += 1
                print(current_cell, ' to ', loop_source_cell, ': wall in the way at ', cell)
                break
            cell = cell + required_direction
        if walls > 0:
            continue
        
        var loop_points = []
        loop_points.append(map.map_to_local(current_cell))
        loop_points.append(map.map_to_local(last_cells[0]))
        loop_points.append(map.map_to_local(last_cells[1]))
        for j in range(len(loop_source_items)-1, i-1, -1):
            loop_points.append(map.map_to_local(loop_source_items[j][1]))
                
        found_loops += 1
        var loop_path = get_template('LoopPath').duplicate()
        paths.add_child(loop_path)
        loop_path.owner = paths
        loop_path.position = Vector2.ZERO
        loop_path.points = PackedVector2Array(loop_points)
        loop_path.visible = true

func remove_children(node):
    for i in range(node.get_child_count()):
        node.remove_child(node.get_child(0))

func move_guard(delta: float):
    while not reached_destination and delta > 0:
        var target_position = map.map_to_local(target_cell)
        var new_position = guard.position + Vector2(direction.x, direction.y) * guard_speed * 256 * delta
        var d1 = target_position - guard.position
        var d2 = new_position - guard.position
        var d = d1 - d2
        if sign(d) == sign(Vector2(direction)):
            guard.position = new_position
            return

        # multiple steps on each frame!
        var delta_consumed = (d1.length() / d2.length()) * delta
        delta -= delta_consumed
        
        guard.position = target_position
        current_cell = target_cell
        mark_current()
        var source = map.get_cell_source_id(0, target_cell + direction)
        if source == -1:
            running = false
            reached_destination = true
            target_cell = current_cell + direction
            target.position = map.map_to_local(target_cell)
            print('marked cells: ', marked_cells)
            # 890: too low
            # 598: too low
            print('loops: ', found_loops)
            return

        if source == 1:
            last_cells.push_front(current_cell)
            if len(last_cells) >= 3:
                var loop_source_cell = last_cells.pop_back()
                loop_source_items.push_back([-direction, loop_source_cell])
                var loop_source = get_template('LoopSource').duplicate()
                loop_sources.add_child(loop_source)
                loop_source.owner = loop_sources
                loop_source.position = map.map_to_local(loop_source_cell)
                loop_source.visible = true

            # turn right
            if direction == Vector2i.DOWN:
                direction = Vector2i.LEFT
                guard.rotation_degrees = 180
            elif direction == Vector2i.LEFT:
                direction = Vector2i.UP
                guard.rotation_degrees = -90
            elif direction == Vector2i.UP:
                direction = Vector2i.RIGHT
                guard.rotation_degrees = 0
            elif direction == Vector2i.RIGHT:
                direction = Vector2i.DOWN
                guard.rotation_degrees = 90
            else:
                push_error("Unknon direction: ", direction)

        target_cell = current_cell + direction
        target.position = map.map_to_local(target_cell)


func parse_input(lines: PackedStringArray):
    var clean_lines = []
    for line in lines:
        if line:
            clean_lines.append(line)
    return clean_lines


func build_map(parsed_input):
    var width = len(parsed_input[0])
    var height = len(parsed_input)
    map.clear()
    for j in height:
        for i in width:
            var source = 0
            if parsed_input[j][i] == '.':
                source = 0
            elif parsed_input[j][i] == '#':
                source = 1
            elif parsed_input[j][i] == '^':
                source = 0
                current_cell = Vector2i(i, j)
                direction = Vector2i.UP
                target_cell = current_cell + direction
                target.position = map.map_to_local(target_cell)
                guard.position = map.map_to_local(current_cell)
                guard.rotation_degrees = -90
            map.set_cell(0, Vector2i(i, j), source, Vector2i.ZERO)
    _on_zoom_pressed()
    

func process(lines: PackedStringArray):
    running = false
    reached_destination = false
    marked_cells = 0
    found_loops = 0
    last_cells = []
    loop_source_items = []
    remove_children(loop_sources)
    remove_children(paths)
    var parsed_input = parse_input(lines)
    build_map(parsed_input)
    mark_current()


func _on_run_pressed(prefix: String='data', suffix: String=''):
    var lines = self.read_input(prefix, suffix)
    process(lines)


func _on_play_toggled(toggled_on: bool) -> void:
    running = toggled_on


func _on_zoom_pressed() -> void:
    var used_rect = map.get_used_rect()
    var size = map.map_to_local(Vector2(used_rect.size.x, used_rect.size.y))
    var viewport_rect = get_viewport_rect()
    zoom_level = min(viewport_rect.size.x/size.x, (viewport_rect.size.y - 64)/size.y)
    var center = viewport_rect.size / 2
    var topleft = center - (size * zoom_level) / 2
    topleft.y += 50
    map.position = topleft
