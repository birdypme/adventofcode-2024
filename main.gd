extends MarginContainer

@export var day_button_template: PackedScene

@onready var rows = $Rows/Days as Container

var regex_day_file = RegEx.new()

func _ready() -> void:
    regex_day_file.compile('day(\\d+)[^\\d]*.tscn')

    var dir = DirAccess.open("res://days")
    dir.list_dir_begin()
    while true:
        var file_name = dir.get_next()
        if not file_name:
            break
        if dir.current_is_dir():
            continue
        var match = regex_day_file.search(file_name)
        if not match:
            continue
        var node = day_button_template.instantiate()
        var day_name = file_name.rsplit('.', true, 1)[0]
        node.name = day_name.to_upper()
        node.text = day_name
        node.pressed.connect(_on_btn_day_pressed.bind(day_name))
        rows.add_child(node)
        node.owner = rows

func _on_btn_day_pressed(day: String):
    var scene = 'res://days/{day}.tscn'.format({'day': day})
    get_tree().change_scene_to_file(scene)
