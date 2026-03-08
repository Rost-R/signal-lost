## ============================================================================
## TRANSMISSION PANEL
## ============================================================================
##
## Purpose: Story transmission display overlay. Shows 1-2 transmission choices
## during between-wave story windows. Player picks one to read and unlock.
## Terminal/CRT aesthetic via _draw().
##
## @author Signal Lost Team
## @version 0.2.0
extends CanvasLayer


## ============================================================================
## SIGNALS
## ============================================================================

signal transmission_selected(transmission: Dictionary)
signal transmission_skipped()


## ============================================================================
## CONSTANTS
## ============================================================================

const BG_COLOR := Color(0.02, 0.04, 0.07, 0.92)
const PANEL_COLOR := Color(0.06, 0.08, 0.12, 0.95)
const BORDER_COLOR := Color(0, 1, 0.53, 0.4)
const TEXT_COLOR := Color(0, 1, 0.53)
const ACCENT_COLOR := Color(0, 0.78, 1)
const SPEAKER_COLOR := Color(0, 0.78, 1)
const STORY_COLOR := Color(0.85, 0.9, 0.85)
const SKIP_COLOR := Color(0.5, 0.5, 0.5)
const HOVER_COLOR := Color(0, 1, 0.53, 0.08)

## Category colors
const CATEGORY_COLORS := {
	"crew_log": Color(0, 0.78, 1),
	"signal": Color(1, 0.72, 0),
	"system": Color(0, 1, 0.53),
	"corruption": Color(1, 0.13, 0.27),
}


## ============================================================================
## STATE
## ============================================================================

var _draw_node: Control
var _is_visible: bool = false
var _choices: Array = []
var _hovered_choice: int = -1  ## 0, 1 = choices, 2 = skip


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

## Show transmission choices.
func show_choices(choices: Array) -> void:
	_choices = choices
	_hovered_choice = -1
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
		_hovered_choice = _get_choice_at(event.position, vp_size)
		_draw_node.queue_redraw()

	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var choice := _get_choice_at(event.position, vp_size)
		_select_choice(choice)


func _unhandled_input(event: InputEvent) -> void:
	if not _is_visible:
		return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_select_choice(0)
				get_viewport().set_input_as_handled()
			KEY_2:
				if _choices.size() >= 2:
					_select_choice(1)
					get_viewport().set_input_as_handled()
			KEY_ESCAPE:
				_select_choice(-1)  ## Skip
				get_viewport().set_input_as_handled()


func _select_choice(index: int) -> void:
	if index >= 0 and index < _choices.size():
		var tx: Dictionary = _choices[index]
		hide_panel()
		transmission_selected.emit(tx)
	elif index == -1 or index == 2:
		hide_panel()
		transmission_skipped.emit()


## ============================================================================
## DRAWING
## ============================================================================

func _on_draw() -> void:
	if not _is_visible or _choices.is_empty():
		return

	var vp_size := _draw_node.get_viewport_rect().size
	var font := ThemeDB.fallback_font
	if not font:
		return

	## Full-screen overlay
	_draw_node.draw_rect(Rect2(Vector2.ZERO, vp_size), BG_COLOR)

	## Center panel
	var panel_w := 440.0
	var choice_h := 120.0
	var panel_h := 60 + _choices.size() * (choice_h + 8) + 40
	var panel_x := (vp_size.x - panel_w) * 0.5
	var panel_y := (vp_size.y - panel_h) * 0.5
	var panel_rect := Rect2(panel_x, panel_y, panel_w, panel_h)

	_draw_node.draw_rect(panel_rect, PANEL_COLOR)
	_draw_node.draw_rect(panel_rect, BORDER_COLOR, false, 1.5)

	var x := panel_x + 20
	var y := panel_y + 30

	## Title
	_draw_node.draw_string(font, Vector2(x, y), "INCOMING TRANSMISSION", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, TEXT_COLOR)
	y += 10

	## Separator
	_draw_node.draw_line(Vector2(x, y + 6), Vector2(panel_x + panel_w - 20, y + 6), BORDER_COLOR, 1.0)
	y += 20

	## Choices
	for i in _choices.size():
		var tx: Dictionary = _choices[i]
		var card_rect := Rect2(x, y, panel_w - 40, choice_h)

		## Card background
		var bg := HOVER_COLOR if _hovered_choice == i else Color(0, 0, 0, 0.2)
		_draw_node.draw_rect(card_rect, bg)
		var border := TEXT_COLOR if _hovered_choice == i else Color(BORDER_COLOR, 0.3)
		_draw_node.draw_rect(card_rect, border, false, 1.0)

		var cx := x + 12
		var cy := y + 18

		## [N] Title
		var key := str(i + 1)
		var title: String = tx.get("title", "Unknown")
		_draw_node.draw_string(font, Vector2(cx, cy), "[%s] %s" % [key, title], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, ACCENT_COLOR)
		cy += 16

		## Speaker
		var speaker: String = tx.get("speaker", "Unknown")
		var category: String = tx.get("category", "crew_log")
		var speaker_col: Color = CATEGORY_COLORS.get(category, SPEAKER_COLOR)
		_draw_node.draw_string(font, Vector2(cx, cy), speaker, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, speaker_col)
		cy += 14

		## Text preview (first ~80 chars)
		var text: String = tx.get("text", "")
		if text.length() > 80:
			text = text.substr(0, 77) + "..."
		_draw_node.draw_string(font, Vector2(cx, cy), text, HORIZONTAL_ALIGNMENT_LEFT, int(panel_w - 64), 10, STORY_COLOR * Color(1, 1, 1, 0.7))
		cy += 14

		## Category tag
		_draw_node.draw_string(font, Vector2(cx, cy + 10), "[%s]" % category.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 9, speaker_col * Color(1, 1, 1, 0.5))

		y += choice_h + 8

	## Skip option
	var skip_col := TEXT_COLOR if _hovered_choice == 2 else SKIP_COLOR
	_draw_node.draw_string(font, Vector2(x, y + 10), "[ESC] Skip transmission", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, skip_col)


## ============================================================================
## HELPERS
## ============================================================================

func _get_choice_at(mouse_pos: Vector2, vp_size: Vector2) -> int:
	var panel_w := 440.0
	var choice_h := 120.0
	var panel_h := 60 + _choices.size() * (choice_h + 8) + 40
	var panel_x := (vp_size.x - panel_w) * 0.5
	var panel_y := (vp_size.y - panel_h) * 0.5

	var x := panel_x + 20
	var y := panel_y + 60

	for i in _choices.size():
		var card_rect := Rect2(x, y, panel_w - 40, choice_h)
		if card_rect.has_point(mouse_pos):
			return i
		y += choice_h + 8

	## Skip button area
	var skip_rect := Rect2(x, y, 200, 24)
	if skip_rect.has_point(mouse_pos):
		return 2

	return -1
