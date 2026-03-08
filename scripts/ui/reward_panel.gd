## ============================================================================
## REWARD PANEL
## ============================================================================
##
## Purpose: Between-wave reward choice UI. Displays 3 reward options.
## Player clicks one to apply it. Terminal/CRT aesthetic via _draw().
##
## @author Signal Lost Team
## @version 0.3.0
extends CanvasLayer


## ============================================================================
## SIGNALS
## ============================================================================

signal reward_selected(reward: Dictionary)


## ============================================================================
## CONSTANTS
## ============================================================================

const BG_COLOR := Color(0.04, 0.06, 0.09, 0.92)
const PANEL_COLOR := Color(0.07, 0.09, 0.14, 0.95)
const BORDER_COLOR := Color(0, 1, 0.53, 0.4)
const BORDER_HIGHLIGHT := Color(0, 1, 0.53, 0.9)
const TEXT_COLOR := Color(0, 1, 0.53)
const TITLE_COLOR := Color(1, 0.72, 0)  # Amber (narrative color)
const ACCENT_COLOR := Color(0, 0.78, 1)  # Cyan
const HOVER_BG := Color(0, 1, 0.53, 0.08)

## Reward type colors
const TYPE_COLORS := {
	"scrap": Color(0, 0.78, 1),        # Cyan
	"heal": Color(0.2, 0.9, 0.4),      # Green
	"power": Color(1, 0.72, 0),        # Amber
	"passive": Color(0.67, 0.27, 1),   # Purple
	"economy": Color(1, 0.84, 0),      # Gold
}


## ============================================================================
## STATE
## ============================================================================

var _draw_node: Control
var _choices: Array = []
var _hovered_index: int = -1
var _is_visible: bool = false


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

## Show the reward panel with 3 choices.
func show_choices(choices: Array) -> void:
	_choices = choices
	_hovered_index = -1
	_is_visible = true
	_draw_node.visible = true
	_draw_node.mouse_filter = Control.MOUSE_FILTER_STOP
	_draw_node.queue_redraw()


## Hide the reward panel.
func hide_panel() -> void:
	_is_visible = false
	_choices.clear()
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
		_hovered_index = _get_card_at(event.position, vp_size)
		_draw_node.queue_redraw()

	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var index: int = _get_card_at(event.position, vp_size)
		if index >= 0 and index < _choices.size():
			var chosen: Dictionary = _choices[index]
			reward_selected.emit(chosen)
			hide_panel()


func _unhandled_input(event: InputEvent) -> void:
	if not _is_visible:
		return
	## Block all input from reaching game while panel is open
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				if _choices.size() > 0:
					reward_selected.emit(_choices[0])
					hide_panel()
					get_viewport().set_input_as_handled()
			KEY_2:
				if _choices.size() > 1:
					reward_selected.emit(_choices[1])
					hide_panel()
					get_viewport().set_input_as_handled()
			KEY_3:
				if _choices.size() > 2:
					reward_selected.emit(_choices[2])
					hide_panel()
					get_viewport().set_input_as_handled()


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

	## Full-screen dim overlay
	_draw_node.draw_rect(Rect2(Vector2.ZERO, vp_size), BG_COLOR)

	## Title
	var title := "// REWARD — CHOOSE ONE //"
	var title_size := font.get_string_size(title, HORIZONTAL_ALIGNMENT_CENTER, -1, 20)
	_draw_node.draw_string(font, Vector2((vp_size.x - title_size.x) * 0.5, 80), title, HORIZONTAL_ALIGNMENT_CENTER, -1, 20, TITLE_COLOR)

	## Subtitle
	var subtitle := "Wave %d Clear" % GameManager.current_wave
	var sub_size := font.get_string_size(subtitle, HORIZONTAL_ALIGNMENT_CENTER, -1, 14)
	_draw_node.draw_string(font, Vector2((vp_size.x - sub_size.x) * 0.5, 105), subtitle, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, TEXT_COLOR * Color(1, 1, 1, 0.6))

	## Draw 3 reward cards
	var card_w := 200.0
	var card_h := 180.0
	var gap := 24.0
	var total_w := card_w * _choices.size() + gap * (_choices.size() - 1)
	var start_x := (vp_size.x - total_w) * 0.5
	var card_y := (vp_size.y - card_h) * 0.5 - 20

	for i in _choices.size():
		var reward: Dictionary = _choices[i]
		var card_x := start_x + i * (card_w + gap)
		var rect := Rect2(card_x, card_y, card_w, card_h)
		var is_hovered: bool = (i == _hovered_index)

		_draw_card(rect, reward, i, is_hovered, font)

	## Footer hint
	var hint := "Press [1] [2] [3] or click to choose"
	var hint_size := font.get_string_size(hint, HORIZONTAL_ALIGNMENT_CENTER, -1, 12)
	_draw_node.draw_string(font, Vector2((vp_size.x - hint_size.x) * 0.5, card_y + card_h + 40), hint, HORIZONTAL_ALIGNMENT_CENTER, -1, 12, TEXT_COLOR * Color(1, 1, 1, 0.4))


func _draw_card(rect: Rect2, reward: Dictionary, index: int, is_hovered: bool, font: Font) -> void:
	var type_color: Color = TYPE_COLORS.get(reward.get("type", "scrap"), ACCENT_COLOR)

	## Card background
	var bg: Color = HOVER_BG if is_hovered else PANEL_COLOR
	_draw_node.draw_rect(rect, bg)

	## Card border
	var border: Color = BORDER_HIGHLIGHT if is_hovered else BORDER_COLOR
	_draw_node.draw_rect(rect, border, false, 2.0 if is_hovered else 1.0)

	var x := rect.position.x + 16
	var y := rect.position.y + 28

	## Key hint
	_draw_node.draw_string(font, Vector2(x, y), "[%d]" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, TEXT_COLOR * Color(1, 1, 1, 0.5))
	y += 24

	## Reward name
	var name_text: String = reward.get("name", "Unknown")
	_draw_node.draw_string(font, Vector2(x, y), name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, type_color)
	y += 22

	## Type tag
	var type_text: String = reward.get("type", "").to_upper()
	_draw_node.draw_string(font, Vector2(x, y), type_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, type_color * Color(1, 1, 1, 0.6))
	y += 20

	## Separator line
	_draw_node.draw_line(Vector2(x, y), Vector2(rect.position.x + rect.size.x - 16, y), BORDER_COLOR, 1.0)
	y += 16

	## Description
	var desc: String = reward.get("description", "")
	_draw_node.draw_string(font, Vector2(x, y), desc, HORIZONTAL_ALIGNMENT_LEFT, int(rect.size.x - 32), 13, TEXT_COLOR)


## ============================================================================
## HELPERS
## ============================================================================

## Get which card index the mouse is over, or -1.
func _get_card_at(mouse_pos: Vector2, vp_size: Vector2) -> int:
	var card_w := 200.0
	var card_h := 180.0
	var gap := 24.0
	var total_w := card_w * _choices.size() + gap * (_choices.size() - 1)
	var start_x := (vp_size.x - total_w) * 0.5
	var card_y := (vp_size.y - card_h) * 0.5 - 20

	for i in _choices.size():
		var card_x := start_x + i * (card_w + gap)
		var rect := Rect2(card_x, card_y, card_w, card_h)
		if rect.has_point(mouse_pos):
			return i

	return -1
