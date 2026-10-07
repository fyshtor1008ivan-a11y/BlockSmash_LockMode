extends Node2D

const GRID_SIZE := 8
const CELL_SIZE := 64
const GAP := 4
const SCORE_PER_BLOCK := 10

@onready var board: Node2D = $Board
@onready var ui_layer: CanvasLayer = $UI

var blocks: Array = []
var score := 0
var level := 1
var combo := 0
var game_over := false
var mode_label: Label
var score_label: Label
var level_label: Label
var info_label: Label
var restart_button: Button

signal group_cleared(points: int, unlocked: int)

func _ready() -> void:
    _build_ui()
    _setup_board()
    _start_game()

func _build_ui() -> void:
    score_label = Label.new()
    score_label.position = Vector2(30, 30)
    score_label.size = Vector2(300, 60)
    score_label.add_theme_font_size_override("font_size", 42)
    score_label.add_theme_color_override("font_color", Color("f5fbff"))
    ui_layer.add_child(score_label)

    level_label = Label.new()
    level_label.position = Vector2(30, 90)
    level_label.size = Vector2(250, 50)
    level_label.add_theme_font_size_override("font_size", 28)
    level_label.add_theme_color_override("font_color", Color("dfe9ff"))
    ui_layer.add_child(level_label)

    mode_label = Label.new()
    mode_label.position = Vector2(420, 30)
    mode_label.size = Vector2(260, 60)
    mode_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    mode_label.add_theme_font_size_override("font_size", 28)
    mode_label.add_theme_color_override("font_color", Color("ffd166"))
    ui_layer.add_child(mode_label)

    info_label = Label.new()
    info_label.position = Vector2(80, 1160)
    info_label.size = Vector2(560, 80)
    info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    info_label.add_theme_font_size_override("font_size", 28)
    info_label.add_theme_color_override("font_color", Color("e8efff"))
    ui_layer.add_child(info_label)

    restart_button = Button.new()
    restart_button.text = "Restart"
    restart_button.position = Vector2(220, 1100)
    restart_button.size = Vector2(280, 80)
    restart_button.focus_mode = Control.FOCUS_NONE
    restart_button.pressed.connect(_on_restart_pressed)
    restart_button.add_theme_font_size_override("font_size", 28)
    ui_layer.add_child(restart_button)

func _setup_board() -> void:
    board.position = Vector2(40, 180)
    board.modulate = Color(1, 1, 1, 1)
    board.z_index = 1

func _start_game() -> void:
    score = 0
    level = 1
    combo = 0
    game_over = false
    _clear_board()
    _fill_board()
    _update_ui()

func _clear_board() -> void:
    for child in board.get_children():
        child.queue_free()
    blocks.clear()

func _fill_board() -> void:
    for y in range(GRID_SIZE):
        var row: Array = []
        for x in range(GRID_SIZE):
            var block = preload("res://block.gd").new()
            block.setup(Vector2i(x, y), _random_color(), _should_lock())
            block.position = Vector2(x, y) * (CELL_SIZE + GAP)
            board.add_child(block)
            row.append(block)
        blocks.append(row)

func _should_lock() -> bool:
    if Global.selected_mode != "lock":
        return false
    return randf() < 0.18 + (level - 1) * 0.04

func _random_color() -> Color:
    var colors = [
        Color("ff5c5c"),
        Color("4ea1ff"),
        Color("4fd67a"),
        Color("ffd166"),
        Color("b77dff"),
        Color("ff9f6e")
    ]
    return colors[randi() % colors.size()]

func _on_restart_pressed() -> void:
    _start_game()

func _input(event: InputEvent) -> void:
    if game_over:
        return
    if event is InputEventMouseButton and event.pressed:
        var local = board.get_local_mouse_position()
        var grid_x = int(local.x / (CELL_SIZE + GAP))
        var grid_y = int(local.y / (CELL_SIZE + GAP))
        if grid_x < 0 or grid_x >= GRID_SIZE or grid_y < 0 or grid_y >= GRID_SIZE:
            return
        var block = blocks[grid_y][grid_x]
        if block == null:
            return
        var group = _connected_group(grid_y, grid_x, block.color)
        if group.size() < 2:
            return
        _remove_group(group)

func _connected_group(start_y: int, start_x: int, target_color: Color) -> Array:
    var visited: Array = []
    var stack: Array = [[start_y, start_x]]
    var result: Array = []

    while stack.size() > 0:
        var pos = stack.pop_back()
        var y = pos[0]
        var x = pos[1]

        if y < 0 or y >= GRID_SIZE or x < 0 or x >= GRID_SIZE:
            continue
        if [y, x] in visited:
            continue

        var block = blocks[y][x]
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

func _remove_group(group: Array) -> void:
    var unlocked_count := 0
    var points := 0
    var to_remove: Array = []

    for block in group:
        if block.is_locked:
            block.unlock()
            unlocked_count += 1
            points += 25
            continue
        to_remove.append(block)
        points += SCORE_PER_BLOCK

    for block in to_remove:
        var pos = block.grid_pos
        blocks[pos.y][pos.x] = null
        block.queue_free()

    _collapse_columns()
    combo += 1
    score += points + unlocked_count * 15
    _update_ui()

    if unlocked_count > 0:
        info_label.text = "Locked block broken! +%d" % (unlocked_count * 15)
    else:
        info_label.text = "Combo x%d" % combo

    if _is_board_empty():
        level += 1
        info_label.text = "Level up!"
        _fill_board()

func _collapse_columns() -> void:
    for x in range(GRID_SIZE):
        var stack: Array = []
        for y in range(GRID_SIZE - 1, -1, -1):
            var block = blocks[y][x]
            if block != null:
                stack.append(block)
                blocks[y][x] = null

        for y in range(GRID_SIZE - 1, -1, -1):
            if stack.is_empty():
                blocks[y][x] = null
            else:
                var block = stack.pop_back()
                block.grid_pos = Vector2i(x, y)
                block.position = Vector2(x, y) * (CELL_SIZE + GAP)
                blocks[y][x] = block

func _is_board_empty() -> bool:
    for row in blocks:
        for cell in row:
            if cell != null:
                return false
    return true

func _update_ui() -> void:
    score_label.text = "Score: %d" % score
    level_label.text = "Level: %d" % level
    mode_label.text = Global.selected_mode.capitalize() + " mode"
    if info_label.text.is_empty():
        info_label.text = "Select a color group"

func _ready_parent() -> void:
    pass
