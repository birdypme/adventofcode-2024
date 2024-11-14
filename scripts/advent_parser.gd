class_name AdventParser
extends Object
## Parsing files for the advent of code day.

## get the full filename to the local file containing the data for this day
## [param day]: the day in 1..24
## [param prefix]: an optional prefix to find the file, with a default of [code]'data'[/code]
## [param suffix]: an optional suffix (empty by default), for instance to get data for the second quest.
static func get_local_filename(day: int, prefix: String='data', suffix: String='') -> String:
    return 'res://data/{prefix}_{day}{suffix}.txt'.format({'prefix': prefix, 'suffix': suffix, 'day': str(day)})

## open the input for the given day, which you can parse with get_line() for instance
## [param day]: the day in 1..24
static func open_input(day: int) -> FileAccess:
    return FileAccess.open(get_local_filename(day), FileAccess.ModeFlags.READ)
    
## open the input for the given day, as an array of strings (one string per line)
## [param day]: the day in 1..24
static func read_input(day: int) -> PackedStringArray:
    var filename = get_local_filename(day)
    print('Opening input file: {filename}'.format({'filename': filename}))
    var lines = FileAccess.get_file_as_string(filename)
    return lines.split('\n')
