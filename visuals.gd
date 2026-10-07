class_name Visuals
extends RefCounted

static func draw_block(ci: CanvasItem, r: Rect2, c: Color) -> void:
    var b := r.size.x * 0.14
    var top_left := r.position
    var top_right := r.position + Vector2(r.size.x, 0.0)
    var bottom_left := r.position + Vector2(0.0, r.size.y)
    var bottom_right := r.end
    var itl := top_left + Vector2(b, b)
    var itr := top_right + Vector2(-b, b)
    var ibl := bottom_left + Vector2(b, -b)
    var ibr := bottom_right - Vector2(b, b)
    ci.draw_colored_polygon(PackedVector2Array([top_left, top_right, itr, itl]), c.lightened(0.4))
    ci.draw_colored_polygon(PackedVector2Array([top_left, itl, ibl, bottom_left]), c.lightened(0.18))
    ci.draw_colored_polygon(PackedVector2Array([top_right, bottom_right, ibr, itr]), c.darkened(0.22))
    ci.draw_colored_polygon(PackedVector2Array([bottom_left, ibl, ibr, bottom_right]), c.darkened(0.4))
    ci.draw_rect(Rect2(itl, r.size - Vector2(b, b) * 2.0), c)
    ci.draw_rect(r, c.darkened(0.6), false, 1.5)
