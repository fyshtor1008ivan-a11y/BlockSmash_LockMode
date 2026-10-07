extends Node2D
class_name Block

var color: Color = Color.WHITE
var is_locked: bool = false
var grid_pos: Vector2i = Vector2i.ZERO

func setup(pos: Vector2i, new_color: Color, locked: bool = false) -> void:
    grid_pos = pos
    color = new_color
    is_locked = locked
    queue_redraw()

func _draw() -> void:
    var base = color
    if is_locked:
        base = base.darkened(0.35)
    Visuals.draw_block(self, Rect2(Vector2.ZERO, Vector2(64, 64)), base)
    if is_locked:
        var w = 24
        var x = 20
        var y = 18
        draw_rect(Rect2(x, y, w, 18), Color("ffd166"), true)
        draw_arc(Vector2(32, 36), 14, 0.2, PI - 0.2, 18, Color("ffd166"), 5)
        draw_rect(Rect2(28, 35, 8, 12), Color("ffd166"), true)

func unlock() -> void:
    is_locked = false
    queue_redraw()
