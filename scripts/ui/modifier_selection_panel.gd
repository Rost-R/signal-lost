## ============================================================================
## MODIFIER SELECTION PANEL
## ============================================================================
##
## Purpose: Pre-run UI overlay where the player picks 1 of 3 run modifiers.
## Displays modifier name, description, rarity, and effects.
## Terminal/CRT aesthetic via _draw().
##
## @author Signal Lost Team
## @version 0.1.0
extends CanvasLayer


## ============================================================================
## SIGNALS
## ============================================================================

signal modifier_chosen(modifier_id: String)
signal modifier_skipped()


## ============================================================================
## CONSTANTS
## ============================================================================

const BG_COLOR := Color(0.04, 0.06, 0.09, 0.95)
const PANEL_COLOR := Color(0.07, 0.09, 0.14, 0.95)
const BORDER_COLOR := Color(0, 1, 0.53, 0.4)
const TEXT_COLOR := Color(0, 1, 0.53)
const TITLE_COLOR := Color(0, 1, 0.53)
const DESC_COLOR := Color(0.7, 0.8, 0.7)
const BTN_HOVER := Color(0, 1, 0.53, 0.12)
const SKIP_COLOR := Color(0.5, 0.5, 0.5)

## Rarity colors
const RARITY_COLORS := {
	"common": Color(0.7, 0.7, 0.7),
	"uncommon": Color(0, 0.78, 1),
	"rare": Color(1, 0.72, 0),
}

const CARD_W := 200.0
const CARD_H := 200.0
const CARD_GAP := 20.0


## ============================================================================
## STATE
## ============================================================================

var _draw_node: Control
var _is_visible: bool = false
var _choices: Array[Dictionary] = []
var _hovered_card: int = -1  ## 0, 1, 2 for cards; 3 for skip
var _cards_rects: Array[Rect2] = []
var _skip_rect: Rect2 = Rect2()


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

## Show the modifier selection screen with 3 choices.
func show_choices(choices: Array[Dictionary]) -> void:
	_choices = choices
	_hovered_card = -1
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

	if event is InputEventMouseMotion:
		_hovered_card = _get_card_at(event.position)
		_draw_node.queue_redraw()

	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var card: int = _get_card_at(event.position)
		if card >= 0 and card < _choices.size():
			var chosen: Dictionary = _choices[card]
			hide_panel()
			modifier_chosen.emit(chosen.get("id", ""))
		elif card == 3:
			hide_panel()
			modifier_skipped.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not _is_visible:
		return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				if _choices.size() > 0:
					hide_panel()
					modifier_chosen.emit(_choices[0].get("id", ""))
					get_viewport().set_input_as_handled()
			KEY_2:
				if _choices.size() > 1:
					hide_panel()
					modifier_chosen.emit(_choices[1].get("id", ""))
					get_viewport().set_input_as_handled()
			KEY_3:
				if _choices.size() > 2:
					hide_panel()
					modifier_chosen.emit(_choices[2].get("id", ""))
					get_viewport().set_input_as_handled()
			KEY_ESCAPE:
				hide_panel()
				modifier_skipped.emit()
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

	## Title
	var title := "SIGNAL MODIFIER DETECTED"
	var title_size := font.get_string_size(title, HORIZONTAL_ALIGNMENT_CENTER, -1, 20)
	_draw_node.draw_string(font, Vector2((vp_size.x - title_size.x) * 0.5, 100), title, HORIZONTAL_ALIGNMENT_CENTER, -1, 20, TITLE_COLOR)

	## Subtitle
	var subtitle := "Select one modifier for this run (or press ESC to skip)"
	var sub_size := font.get_string_size(subtitle, HORIZONTAL_ALIGNMENT_CENTER, -1, 12)
	_draw_node.draw_string(font, Vector2((vp_size.x - sub_size.x) * 0.5, 124), subtitle, HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color(TEXT_COLOR, 0.6))

	## Cards
	_cards_rects.clear()
	var total_w: float = CARD_W * _choices.size() + CARD_GAP * (_choices.size() - 1)
	var start_x: float = (vp_size.x - total_w) * 0.5
	var card_y: float = 160.0

	for i in _choices.size():
		var card_x: float = start_x + i * (CARD_W + CARD_GAP)
		var card_rect := Rect2(card_x, card_y, CARD_W, CARD_H)
		_cards_rects.append(card_rect)
		_draw_card(i, card_rect, font)

	## Skip button
	var skip_text := "[ESC] No Modifier"
	var skip_size := font.get_string_size(skip_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 13)
	var skip_w := skip_size.x + 32
	var skip_h := 32.0
	var skip_x := (vp_size.x - skip_w) * 0.5
	var skip_y := card_y + CARD_H + 40
	_skip_rect = Rect2(skip_x, skip_y, skip_w, skip_h)

	var skip_bg := BTN_HOVER if _hovered_card == 3 else Color(0, 0, 0, 0)
	_draw_node.draw_rect(_skip_rect, skip_bg)
	_draw_node.draw_rect(_skip_rect, SKIP_COLOR if _hovered_card != 3 else TEXT_COLOR, false, 1.0)
	_draw_node.draw_string(font, Vector2(skip_x + 16, skip_y + 22), skip_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, SKIP_COLOR if _hovered_card != 3 else TEXT_COLOR)


func _draw_card(index: int, rect: Rect2, font: Font) -> void:
	var choice: Dictionary = _choices[index]
	var is_hovered := _hovered_card == index

	## Card background
	var bg := Color(PANEL_COLOR.r, PANEL_COLOR.g, PANEL_COLOR.b, 1.0) if is_hovered else PANEL_COLOR
	_draw_node.draw_rect(rect, bg)

	## Card border
	var rarity: String = choice.get("rarity", "common")
	var rarity_color: Color = RARITY_COLORS.get(rarity, Color.GRAY)
	var border_color := rarity_color if is_hovered else Color(rarity_color, 0.4)
	_draw_node.draw_rect(rect, border_color, false, 2.0 if is_hovered else 1.0)

	var x := rect.position.x + 12
	var y := rect.position.y + 24

	## Hotkey badge
	var hotkey := "[%d]" % (index + 1)
	_draw_node.draw_string(font, Vector2(x, y), hotkey, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(TEXT_COLOR, 0.5))

	## Rarity tag
	var rarity_text := rarity.to_upper()
	var rarity_size := font.get_string_size(rarity_text, HORIZONTAL_ALIGNMENT_RIGHT, -1, 10)
	_draw_node.draw_string(font, Vector2(rect.position.x + CARD_W - 12 - rarity_size.x, y), rarity_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, rarity_color)

	y += 22

	## Name
	var mod_name: String = choice.get("name", "Unknown")
	_draw_node.draw_string(font, Vector2(x, y), mod_name, HORIZONTAL_ALIGNMENT_LEFT, int(CARD_W - 24), 15, TEXT_COLOR if not is_hovered else Color.WHITE)

	y += 20

	## Separator
	_draw_node.draw_line(Vector2(x, y), Vector2(rect.position.x + CARD_W - 12, y), Color(BORDER_COLOR, 0.3), 1.0)
	y += 12

	## Description (word-wrapped)
	var desc: String = choice.get("description", "")
	var lines := _word_wrap(desc, 28)
	for line in lines:
		_draw_node.draw_string(font, Vector2(x, y), line, HORIZONTAL_ALIGNMENT_LEFT, int(CARD_W - 24), 11, DESC_COLOR)
		y += 14


## ============================================================================
## HELPERS
## ============================================================================

func _get_card_at(mouse_pos: Vector2) -> int:
	for i in _cards_rects.size():
		if _cards_rects[i].has_point(mouse_pos):
			return i
	if _skip_rect.has_point(mouse_pos):
		return 3
	return -1


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
