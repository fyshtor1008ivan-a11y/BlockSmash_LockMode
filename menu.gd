extends Control

const MAIN_SCENE = "res://main.tscn"

var classic_button: Button
var lock_button: Button
var title_label: Label
var subtitle_label: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _build_ui()

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color("101a4a")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var gradient := Gradient.new()
    gradient.set_color(0, Color("0e1a52"))
    gradient.set_color(1, Color("3c1d7e"))
    var tex := GradientTexture2D.new()
    tex.gradient = gradient
    tex.fill_from = Vector2(0.5, 0.0)
    tex.fill_to = Vector2(0.5, 1.0)
    tex.width = 720
    tex.height = 1280
    var bg_tex := TextureRect.new()
    bg_tex.texture = tex
    bg_tex.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    bg_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(bg_tex)

    title_label = Label.new()
    title_label.text = "BLOCK\nSMASH"
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    title_label.add_theme_font_size_override("font_size", 120)
    title_label.set("theme_override_colors/font_color", Color("eaf6ff"))
    title_label.set("theme_override_colors/font_outline_color", Color("273a9c"))
    title_label.add_theme_constant_override("outline_size", 20)
    title_label.position = Vector2(60, 120)
    title_label.size = Vector2(600, 260)
    add_child(title_label)

    subtitle_label = Label.new()
    subtitle_label.text = "Choose your mode"
    subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle_label.position = Vector2(0, 420)
    subtitle_label.size = Vector2(720, 80)
    subtitle_label.add_theme_font_size_override("font_size", 32)
    subtitle_label.add_theme_color_override("font_color", Color("dfe9ff"))
    add_child(subtitle_label)

    classic_button = Button.new()
    classic_button.text = "Classic"
    classic_button.position = Vector2(160, 540)
    classic_button.size = Vector2(400, 110)
    classic_button.focus_mode = Control.FOCUS_NONE
    _style_button(classic_button, Color("41c784"))
    classic_button.pressed.connect(_on_classic_pressed)
    add_child(classic_button)

    lock_button = Button.new()
    lock_button.text = "Lock Mode"
    lock_button.position = Vector2(160, 700)
    lock_button.size = Vector2(400, 110)
    lock_button.focus_mode = Control.FOCUS_NONE
    _style_button(lock_button, Color("ffb703"))
    lock_button.pressed.connect(_on_lock_pressed)
    add_child(lock_button)

func _style_button(button: Button, base_color: Color) -> void:
    var normal := StyleBoxFlat.new()
    normal.bg_color = base_color
    normal.corner_radius_top_left = 24
    normal.corner_radius_top_right = 24
    normal.corner_radius_bottom_left = 24
    normal.corner_radius_bottom_right = 24
    normal.border_width_bottom = 8
    normal.border_color = base_color.darkened(0.35)
    button.add_theme_stylebox_override("normal", normal)

    var hover := StyleBoxFlat.new()
    hover.bg_color = base_color.lightened(0.1)
    hover.corner_radius_top_left = 24
    hover.corner_radius_top_right = 24
    hover.corner_radius_bottom_left = 24
    hover.corner_radius_bottom_right = 24
    hover.border_width_bottom = 8
    hover.border_color = base_color.darkened(0.25)
    button.add_theme_stylebox_override("hover", hover)

    var pressed := StyleBoxFlat.new()
    pressed.bg_color = base_color.darkened(0.12)
    pressed.corner_radius_top_left = 24
    pressed.corner_radius_top_right = 24
    pressed.corner_radius_bottom_left = 24
    pressed.corner_radius_bottom_right = 24
    pressed.border_width_bottom = 4
    pressed.border_color = base_color.darkened(0.35)
    button.add_theme_stylebox_override("pressed", pressed)

    button.add_theme_font_size_override("font_size", 42)
    button.add_theme_color_override("font_color", Color.WHITE)

func _on_classic_pressed() -> void:
    Global.selected_mode = "classic"
    get_tree().change_scene_to_file(MAIN_SCENE)

func _on_lock_pressed() -> void:
    Global.selected_mode = "lock"
    get_tree().change_scene_to_file(MAIN_SCENE)
