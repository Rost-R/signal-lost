## ============================================================================
## MAIN MENU
## ============================================================================
##
## Purpose: Simple main menu with terminal aesthetic.
## Start Game, Quit. That's it for MVP.
##
## @author Signal Lost Team
## @version 0.1.0
extends Control


func _ready() -> void:
	## Center on screen
	set_anchors_preset(PRESET_FULL_RECT)


func _draw() -> void:
	var vp := get_viewport_rect().size
	var font := ThemeDB.fallback_font
	if not font:
		return

	var bg_color := Color(0.039, 0.055, 0.09)
	var green := Color(0, 1, 0.53)
	var dim_green := Color(0, 1, 0.53, 0.5)

	## Background
	draw_rect(Rect2(Vector2.ZERO, vp), bg_color)

	## Title
	var title := "SIGNAL LOST"
	var title_size := font.get_string_size(title, HORIZONTAL_ALIGNMENT_CENTER, -1, 32)
	draw_string(font, Vector2((vp.x - title_size.x) * 0.5, vp.y * 0.3), title, HORIZONTAL_ALIGNMENT_CENTER, -1, 32, green)

	## Subtitle
	var sub := "Roguelike Tower Defense"
	var sub_size := font.get_string_size(sub, HORIZONTAL_ALIGNMENT_CENTER, -1, 14)
	draw_string(font, Vector2((vp.x - sub_size.x) * 0.5, vp.y * 0.3 + 30), sub, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, dim_green)

	## Menu options
	var options := ["[ENTER] START GAME", "[ESC] QUIT"]
	for i in options.size():
		var opt_size := font.get_string_size(options[i], HORIZONTAL_ALIGNMENT_CENTER, -1, 16)
		draw_string(font, Vector2((vp.x - opt_size.x) * 0.5, vp.y * 0.55 + i * 30), options[i], HORIZONTAL_ALIGNMENT_CENTER, -1, 16, green)

	## Version
	draw_string(font, Vector2(vp.x - 100, vp.y - 12), "v0.1.0 MVP", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, dim_green)

	## Blinking cursor
	if int(Time.get_ticks_msec() / 500) % 2 == 0:
		draw_string(font, Vector2((vp.x - 8) * 0.5, vp.y * 0.7), "_", HORIZONTAL_ALIGNMENT_CENTER, -1, 16, green)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ENTER, KEY_KP_ENTER:
				get_tree().change_scene_to_file("res://scenes/game/game.tscn")
			KEY_ESCAPE:
				get_tree().quit()


func _process(_delta: float) -> void:
	queue_redraw()
