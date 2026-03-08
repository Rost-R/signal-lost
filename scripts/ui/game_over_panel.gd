## ============================================================================
## GAME OVER PANEL
## ============================================================================
##
## Purpose: End-of-run screen. Shows victory/defeat, run stats summary,
## and options to restart or return to main menu.
## Terminal/CRT aesthetic via _draw().
##
## @author Signal Lost Team
## @version 0.3.0
extends CanvasLayer


## ============================================================================
## SIGNALS
## ============================================================================

signal restart_requested()
signal main_menu_requested()


## ============================================================================
## CONSTANTS
## ============================================================================

const BG_COLOR := Color(0.04, 0.06, 0.09, 0.95)
const PANEL_COLOR := Color(0.07, 0.09, 0.14, 0.95)
const BORDER_COLOR := Color(0, 1, 0.53, 0.4)
const TEXT_COLOR := Color(0, 1, 0.53)
const VICTORY_COLOR := Color(0, 1, 0.53)
const DEFEAT_COLOR := Color(1, 0.13, 0.27)
const ACCENT_COLOR := Color(0, 0.78, 1)
const STAT_COLOR := Color(1, 0.72, 0)
const BTN_HOVER := Color(0, 1, 0.53, 0.12)


## ============================================================================
## STATE
## ============================================================================

var _draw_node: Control
var _is_visible: bool = false
var _victory: bool = false
var _stats: Dictionary = {}
var _ending: Dictionary = {}  ## { id, name, description }
var _hovered_button: int = -1  # 0 = restart, 1 = menu


## ============================================================================
## LIFECYCLE
## ============================================================================

func _ready() -> void:
	_draw_node = Control.new()
	_draw_node.set_anchors_preset(Control.PRESET_FULL_RECT)
	_draw_node.mouse_filter = Control.MOUSE_FILTER_STOP
	_draw_node.draw.connect(_on_draw)
	_draw_node.gui_input.connect(_on_gui_input)
	add_child(_draw_node)
	hide_panel()


## ============================================================================
## PUBLIC API
## ============================================================================

## Show the game over screen with run summary and ending.
func show_results(victory: bool, ending: Dictionary = {}) -> void:
	_victory = victory
	_ending = ending
	_stats = RunManager.get_run_summary()
	_stats["core_hp"] = GameManager.core_hp
	_stats["max_core_hp"] = GameManager.STARTING_CORE_HP
	_hovered_button = -1
	_is_visible = true
	_draw_node.visible = true
	_draw_node.mouse_filter = Control.MOUSE_FILTER_STOP
	_draw_node.queue_redraw()


## Hide the panel.
func hide_panel() -> void:
	_is_visible = false
	_draw_node.visible = false
	_draw_node.mouse_filter = Control.MOUSE_FILTER_IGNORE


## ============================================================================
## INPUT
## ============================================================================

func _on_gui_input(event: InputEvent) -> void:
	if not _is_visible:
		return

	var vp_size := _draw_node.get_viewport_rect().size

	if event is InputEventMouseMotion:
		_hovered_button = _get_button_at(event.position, vp_size)
		_draw_node.queue_redraw()

	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var btn: int = _get_button_at(event.position, vp_size)
		if btn == 0:
			hide_panel()
			restart_requested.emit()
		elif btn == 1:
			hide_panel()
			main_menu_requested.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not _is_visible:
		return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_R:
				hide_panel()
				restart_requested.emit()
				get_viewport().set_input_as_handled()
			KEY_ESCAPE:
				hide_panel()
				main_menu_requested.emit()
				get_viewport().set_input_as_handled()


## ============================================================================
## DRAWING
## ============================================================================

func _on_draw() -> void:
	if not _is_visible:
		return

	var vp_size := _draw_node.get_viewport_rect().size
	var font := ThemeDB.fallback_font
	if not font:
		return

	## Full-screen overlay
	_draw_node.draw_rect(Rect2(Vector2.ZERO, vp_size), BG_COLOR)

	## Center panel
	var panel_w := 420.0
	var has_ending := not _ending.is_empty() and _ending.has("name")
	var panel_h := 480.0 if has_ending else 380.0
	var panel_x := (vp_size.x - panel_w) * 0.5
	var panel_y := (vp_size.y - panel_h) * 0.5 - 20
	var panel_rect := Rect2(panel_x, panel_y, panel_w, panel_h)

	_draw_node.draw_rect(panel_rect, PANEL_COLOR)
	_draw_node.draw_rect(panel_rect, BORDER_COLOR, false, 1.5)

	var x := panel_x + 24
	var y := panel_y + 36

	## Title — use ending name if available
	var title := ""
	var title_color := VICTORY_COLOR if _victory else DEFEAT_COLOR
	if has_ending:
		title = _ending.get("name", "").to_upper()
		## Color based on ending type
		var ending_id: String = _ending.get("id", "")
		match ending_id:
			"resistance": title_color = VICTORY_COLOR
			"transcendence": title_color = Color(0.67, 0.44, 1)  # Purple
			"signal_origin": title_color = ACCENT_COLOR
			"synthesis": title_color = Color(1, 0.84, 0)  # Gold
	else:
		title = "SIGNAL FOUND" if _victory else "SIGNAL LOST"

	var title_size := font.get_string_size(title, HORIZONTAL_ALIGNMENT_CENTER, -1, 22)
	_draw_node.draw_string(font, Vector2((vp_size.x - title_size.x) * 0.5, y), title, HORIZONTAL_ALIGNMENT_CENTER, -1, 22, title_color)
	y += 16

	## Ending description or simple subtitle
	if has_ending:
		var desc: String = _ending.get("description", "")
		## Word-wrap the description
		var max_chars := 50
		var lines := _word_wrap(desc, max_chars)
		for line in lines:
			var line_size := font.get_string_size(line, HORIZONTAL_ALIGNMENT_CENTER, -1, 11)
			_draw_node.draw_string(font, Vector2((vp_size.x - line_size.x) * 0.5, y + 16), line, HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color(title_color, 0.7))
			y += 14
		y += 12
	else:
		var subtitle := "All waves cleared!" if _victory else "Core destroyed."
		var sub_size := font.get_string_size(subtitle, HORIZONTAL_ALIGNMENT_CENTER, -1, 13)
		_draw_node.draw_string(font, Vector2((vp_size.x - sub_size.x) * 0.5, y + 16), subtitle, HORIZONTAL_ALIGNMENT_CENTER, -1, 13, TEXT_COLOR * Color(1, 1, 1, 0.6))
		y += 44

	## Separator
	_draw_node.draw_line(Vector2(x, y), Vector2(panel_x + panel_w - 24, y), BORDER_COLOR, 1.0)
	y += 20

	## Stats
	var stats_list := [
		["Waves Survived", str(_stats.get("waves_survived", 0)) + " / " + str(GameManager.MAX_WAVES)],
		["Enemies Destroyed", str(_stats.get("enemies_killed", 0))],
		["Scrap Earned", str(_stats.get("scrap_earned", 0))],
		["Core HP", str(_stats.get("core_hp", 0)) + " / " + str(_stats.get("max_core_hp", 20))],
		["Rewards Chosen", str(_stats.get("rewards", []).size())],
		["Run Seed", str(_stats.get("seed", 0))],
	]

	for stat in stats_list:
		_draw_node.draw_string(font, Vector2(x, y), stat[0], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, TEXT_COLOR)
		_draw_node.draw_string(font, Vector2(panel_x + panel_w - 24, y), stat[1], HORIZONTAL_ALIGNMENT_RIGHT, -1, 13, STAT_COLOR)
		y += 22

	y += 16

	## Separator
	_draw_node.draw_line(Vector2(x, y), Vector2(panel_x + panel_w - 24, y), BORDER_COLOR, 1.0)
	y += 24

	## Buttons
	var btn_w := 140.0
	var btn_h := 36.0
	var btn_gap := 24.0
	var btns_total := btn_w * 2 + btn_gap
	var btn_start_x := (vp_size.x - btns_total) * 0.5

	## Restart button
	var restart_rect := Rect2(btn_start_x, y, btn_w, btn_h)
	var restart_bg := BTN_HOVER if _hovered_button == 0 else PANEL_COLOR
	_draw_node.draw_rect(restart_rect, restart_bg)
	_draw_node.draw_rect(restart_rect, VICTORY_COLOR if _hovered_button == 0 else BORDER_COLOR, false, 1.5 if _hovered_button == 0 else 1.0)
	_draw_node.draw_string(font, Vector2(restart_rect.position.x + 12, y + 24), "[R] Restart", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, TEXT_COLOR)

	## Menu button
	var menu_rect := Rect2(btn_start_x + btn_w + btn_gap, y, btn_w, btn_h)
	var menu_bg := BTN_HOVER if _hovered_button == 1 else PANEL_COLOR
	_draw_node.draw_rect(menu_rect, menu_bg)
	_draw_node.draw_rect(menu_rect, DEFEAT_COLOR if _hovered_button == 1 else BORDER_COLOR, false, 1.5 if _hovered_button == 1 else 1.0)
	_draw_node.draw_string(font, Vector2(menu_rect.position.x + 12, y + 24), "[ESC] Menu", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, TEXT_COLOR)


## ============================================================================
## HELPERS
## ============================================================================

func _get_button_at(mouse_pos: Vector2, vp_size: Vector2) -> int:
	var panel_w := 420.0
	var has_ending := not _ending.is_empty() and _ending.has("name")
	var panel_h := 480.0 if has_ending else 380.0
	var panel_y := (vp_size.y - panel_h) * 0.5 - 20

	var btn_w := 140.0
	var btn_h := 36.0
	var btn_gap := 24.0
	var btns_total := btn_w * 2 + btn_gap
	var btn_start_x := (vp_size.x - btns_total) * 0.5
	## Buttons at bottom of panel
	var btn_y := panel_y + panel_h - btn_h - 24

	var restart_rect := Rect2(btn_start_x, btn_y, btn_w, btn_h)
	if restart_rect.has_point(mouse_pos):
		return 0

	var menu_rect := Rect2(btn_start_x + btn_w + btn_gap, btn_y, btn_w, btn_h)
	if menu_rect.has_point(mouse_pos):
		return 1

	return -1


## Simple word wrap for ending description.
func _word_wrap(text: String, max_chars: int) -> Array[String]:
	var lines: Array[String] = []
	var words := text.split(" ")
	var current_line := ""
	for word in words:
		if current_line.length() + word.length() + 1 > max_chars and current_line != "":
			lines.append(current_line)
			current_line = word
		elif current_line == "":
			current_line = word
		else:
			current_line += " " + word
	if current_line != "":
		lines.append(current_line)
	return lines
