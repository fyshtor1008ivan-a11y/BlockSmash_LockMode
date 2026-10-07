extends Node2D

signal group_cleared(points: int, unlocked: int)

@export var rows: int = 8
@export var cols: int = 8
@export var cell_size: int = 64
@export var gap: int = 4
@export var lock_mode: bool = false

var cells: Array = []
var colors: Array[Color] = [
    Color("ff5c5c"),
    Color("4ea1ff"),
    Color("4fd67a"),
    Color("ffd166"),
    Color("b77dff"),
    Color("ff9f6e")
]

func _ready() -> void:
    generate_board()

func generate_board() -> void:
    for child in get_children():
        child.queue_free()
    cells.clear()

    for y in range(rows):
        var row: Array = []
        for x in range(cols):
            var block = preload("res://block.gd").new()
            block.setup(Vector2i(x, y), _random_color(), lock_mode and randf() < 0.18)
            block.position = Vector2(x, y) * Vector2(cell_size + gap, cell_size + gap)
            add_child(block)
            row.append(block)
        cells.append(row)

func _random_color() -> Color:
    return colors[randi() % colors.size()]

func get_group(start_y: int, start_x: int, target_color: Color) -> Array:
    var visited: Array = []
    var stack: Array = [[start_y, start_x]]
    var result: Array = []

    while stack.size() > 0:
        var pos = stack.pop_back()
        var y = pos[0]
        var x = pos[1]

        if y < 0 or y >= rows or x < 0 or x >= cols:
            continue
        if [y, x] in visited:
            continue

        var block = cells[y][x]
        if block == null:
            continue
        if block.color.distance_to(target_color) > 0.05:
            continue

        visited.append([y, x])
        result.append(block)

        stack.append([y + 1, x])
        stack.append([y - 1, x])
        stack.append([y, x + 1])
        stack.append([y, x - 1])

    return result

func clear_group(group: Array) -> int:
    var unlocked := 0
    var points := 0
    for block in group:
        if block.is_locked:
            block.unlock()
            unlocked += 1
            points += 25
        else:
            points += 10
            var pos = block.grid_pos
            cells[pos.y][pos.x] = null
            block.queue_free()

    collapse_board()
    emit_signal("group_cleared", points, unlocked)
    return points

func collapse_board() -> void:
    for x in range(cols):
        var stack: Array = []
        for y in range(rows - 1, -1, -1):
            var block = cells[y][x]
            if block != null:
                stack.append(block)
                cells[y][x] = null
        for y in range(rows - 1, -1, -1):
            if stack.is_empty():
                break
            var block = stack.pop_back()
            block.grid_pos = Vector2i(x, y)
            block.position = Vector2(x, y) * Vector2(cell_size + gap, cell_size + gap)
            cells[y][x] = block

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        var local = get_local_mouse_position()
        var gx = int(local.x / (cell_size + gap))
        var gy = int(local.y / (cell_size + gap))
        if gx < 0 or gx >= cols or gy < 0 or gy >= rows:
            return
        var block = cells[gy][gx]
        if block == null:
            return
        var group = get_group(gy, gx, block.color)
        if group.size() >= 2:
            clear_group(group)
