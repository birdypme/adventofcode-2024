extends "res://days/day.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.day_number = 6
    self.day_suffix = ''
    super._ready()
    reached_destination = false
    marked_cells = 0
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
@onready var play_button = find_child('Play') as CheckButton
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
        find_child('BlinkDisc2').visible = not find_child('BlinkDisc2').visible

var current_cell = Vector2i.ZERO
var target_cell = Vector2i.ZERO
var direction = Vector2i.UP
@onready var guard_speed_control = find_child('GuardSpeed') as SpinBox
@export var guard_speed: float = 1.1:  # in tile/s
    get:
        if guard_speed_control != null:
            return guard_speed_control.value
        return guard_speed
    set(value):
        if guard_speed_control != null:
            guard_speed_control.value = value
        guard_speed_control = value
        

var marked_cells = 0
func mark_current():
    var source = map.get_cell_source_id(0, current_cell)
    if source == 0:
        map.set_cell(0, current_cell, 2, Vector2i.ZERO)
        marked_cells = marked_cells + 1

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
        var delta_consumed = (d2.length() / d1.length()) * delta
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
            return

        if source == 1:
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


func process(lines: PackedStringArray):
    running = false
    reached_destination = false
    marked_cells = 0
    var parsed_input = parse_input(lines)
    var width = len(parsed_input[0])
    var height = len(parsed_input)
    map.clear()
    for j in height:
        for i in width:
            var source = 0
            if lines[j][i] == '.':
                source = 0
            elif lines[j][i] == '#':
                source = 1
            elif lines[j][i] == '^':
                source = 0
                current_cell = Vector2i(i, j)
                direction = Vector2i.UP
                target_cell = current_cell + direction
                target.position = map.map_to_local(target_cell)
                guard.position = map.map_to_local(current_cell)
                guard.rotation_degrees = -90
            map.set_cell(0, Vector2i(i, j), source, Vector2i.ZERO)
    mark_current()
    _on_zoom_pressed()


func _on_run_pressed(prefix: String='data', suffix: String=''):
    var lines = self.read_input(prefix, suffix)
    process(lines)


func process2(lines: PackedStringArray):
    running = false
    reached_destination = false
    marked_cells = 0
    var parsed_input = parse_input(lines)
    print('not implemented run 2')


func _on_run_2_pressed(prefix: String='data', suffix: String=''):
    var lines = self.read_input(prefix, suffix)
    process2(lines)


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
