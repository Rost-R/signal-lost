## ============================================================================
## GAME HUD
## ============================================================================
##
## Purpose: In-game heads-up display. Shows core HP, resources, wave info,
## tower selection panel, and selected tower info.
## All drawn via _draw() for the CRT aesthetic.
##
## @author Signal Lost Team
## @version 0.1.0
class_name GameHUD
extends CanvasLayer


## ============================================================================
## SIGNALS
## ============================================================================

signal tower_type_selected(tower_id: String)
signal start_wave_pressed()
signal tower_upgrade_requested()
signal tower_sell_requested()


## ============================================================================
## CONSTANTS
## ============================================================================

const PANEL_COLOR := Color(0.04, 0.06, 0.09, 0.85)
const BORDER_COLOR := Color(0, 1, 0.53, 0.3)
const TEXT_COLOR := Color(0, 1, 0.53)  # Terminal green
const ACCENT_COLOR := Color(0, 0.78, 1)  # Cyan
const WARNING_COLOR := Color(1, 0.73, 0)  # Amber
const DANGER_COLOR := Color(1, 0.13, 0.27)  # Red

const TOWER_OPTIONS := [
	{ "id": "pulse_emitter", "name": "Pulse", "cost": 100, "key": "1", "color": Color(0, 0.78, 1) },
	{ "id": "arc_relay", "name": "Arc", "cost": 150, "key": "2", "color": Color(0.27, 0.53, 1) },
	{ "id": "cryo_node", "name": "Cryo", "cost": 120, "key": "3", "color": Color(0.53, 0.87, 1) },
]


## ============================================================================
## STATE
## ============================================================================

var selected_tower_index: int = -1
var _info_panel: Control
var _draw_node: Control


## ============================================================================
## LIFECYCLE
## ============================================================================

func _ready() -> void:
	## Create a Control node for drawing the HUD
	_draw_node = Control.new()
	_draw_node.set_anchors_preset(Control.PRESET_FULL_RECT)
	_draw_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_draw_node.draw.connect(_on_draw)
	add_child(_draw_node)

	GameManager.resources_changed.connect(func(_v: int): _draw_node.queue_redraw())
	GameManager.core_hp_changed.connect(func(_v: int): _draw_node.queue_redraw())
	GameManager.wave_started.connect(func(_v: int): _draw_node.queue_redraw())
	GameManager.wave_completed.connect(func(_v: int): _draw_node.queue_redraw())
	GameManager.game_phase_changed.connect(func(_v: GameManager.GamePhase): _draw_node.queue_redraw())


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		## Tower selection via number keys
		match event.keycode:
			KEY_1:
				_select_tower(0)
			KEY_2:
				_select_tower(1)
			KEY_3:
				_select_tower(2)
			KEY_ESCAPE:
				_select_tower(-1)  # Deselect
			KEY_SPACE:
				if GameManager.current_phase == GameManager.GamePhase.BUILD or \
				   GameManager.current_phase == GameManager.GamePhase.BETWEEN_WAVES:
					start_wave_pressed.emit()


## ============================================================================
## PUBLIC API
## ============================================================================

func get_selected_tower_id() -> String:
	if selected_tower_index < 0 or selected_tower_index >= TOWER_OPTIONS.size():
		return ""
	return TOWER_OPTIONS[selected_tower_index]["id"]


## ============================================================================
## PRIVATE
## ============================================================================

func _select_tower(index: int) -> void:
	if index == selected_tower_index:
		selected_tower_index = -1  # Toggle off
	else:
		selected_tower_index = index
	if selected_tower_index >= 0:
		tower_type_selected.emit(get_selected_tower_id())
	_draw_node.queue_redraw()


## ============================================================================
## DRAWING
## ============================================================================

func _on_draw() -> void:
	var vp_size := _draw_node.get_viewport_rect().size
	_draw_top_bar(vp_size)
	_draw_tower_panel(vp_size)
	_draw_phase_indicator(vp_size)
	_draw_wave_info(vp_size)


func _draw_top_bar(vp_size: Vector2) -> void:
	var font := ThemeDB.fallback_font
	if not font:
		return

	## Background
	_draw_node.draw_rect(Rect2(0, 0, vp_size.x, 32), PANEL_COLOR)
	_draw_node.draw_line(Vector2(0, 32), Vector2(vp_size.x, 32), BORDER_COLOR, 1.0)

	## Core HP
	var hp_color := TEXT_COLOR
	var hp_ratio := float(GameManager.core_hp) / GameManager.STARTING_CORE_HP
	if hp_ratio < 0.25:
		hp_color = DANGER_COLOR
	elif hp_ratio < 0.5:
		hp_color = WARNING_COLOR
	_draw_node.draw_string(font, Vector2(12, 22), "CORE: %d/%d" % [GameManager.core_hp, GameManager.STARTING_CORE_HP], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, hp_color)

	## Resources
	_draw_node.draw_string(font, Vector2(220, 22), "RES: %d" % GameManager.resources, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ACCENT_COLOR)

	## Wave
	_draw_node.draw_string(font, Vector2(400, 22), "WAVE: %d/%d" % [GameManager.current_wave, GameManager.MAX_WAVES], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, TEXT_COLOR)


func _draw_tower_panel(vp_size: Vector2) -> void:
	var font := ThemeDB.fallback_font
	if not font:
		return

	## Bottom panel
	var panel_h := 64.0
	var panel_y := vp_size.y - panel_h
	_draw_node.draw_rect(Rect2(0, panel_y, vp_size.x, panel_h), PANEL_COLOR)
	_draw_node.draw_line(Vector2(0, panel_y), Vector2(vp_size.x, panel_y), BORDER_COLOR, 1.0)

	## Tower buttons
	var btn_w := 120.0
	var btn_h := 44.0
	var start_x := 12.0
	var btn_y := panel_y + 10.0

	for i in TOWER_OPTIONS.size():
		var opt: Dictionary = TOWER_OPTIONS[i]
		var rect := Rect2(start_x + i * (btn_w + 8), btn_y, btn_w, btn_h)

		## Button background
		var bg_color := PANEL_COLOR
		if i == selected_tower_index:
			bg_color = Color(opt["color"], 0.2)
		_draw_node.draw_rect(rect, bg_color)

		## Border
		var border: Color = opt["color"] if i == selected_tower_index else BORDER_COLOR
		_draw_node.draw_rect(rect, border, false, 1.0)

		## Text
		var can_afford: bool = GameManager.resources >= opt["cost"]
		var text_col: Color = opt["color"] if can_afford else Color(0.4, 0.4, 0.4)
		_draw_node.draw_string(font, Vector2(rect.position.x + 6, rect.position.y + 18), "[%s] %s" % [opt["key"], opt["name"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, text_col)
		_draw_node.draw_string(font, Vector2(rect.position.x + 6, rect.position.y + 34), "$%d" % opt["cost"], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, text_col * Color(1, 1, 1, 0.7))

	## Start Wave button (during build phase)
	if GameManager.current_phase == GameManager.GamePhase.BUILD or \
	   GameManager.current_phase == GameManager.GamePhase.BETWEEN_WAVES:
		var sw_rect := Rect2(vp_size.x - 180, btn_y, 160, btn_h)
		_draw_node.draw_rect(sw_rect, Color(0, 1, 0.53, 0.1))
		_draw_node.draw_rect(sw_rect, TEXT_COLOR, false, 1.5)
		_draw_node.draw_string(font, Vector2(sw_rect.position.x + 10, sw_rect.position.y + 18), "[SPACE]", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, TEXT_COLOR * Color(1, 1, 1, 0.6))
		_draw_node.draw_string(font, Vector2(sw_rect.position.x + 10, sw_rect.position.y + 34), "START WAVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, TEXT_COLOR)


func _draw_phase_indicator(vp_size: Vector2) -> void:
	var font := ThemeDB.fallback_font
	if not font:
		return

	var phase_text := ""
	var phase_color := TEXT_COLOR
	match GameManager.current_phase:
		GameManager.GamePhase.BUILD:
			phase_text = "[ BUILD PHASE ]"
		GameManager.GamePhase.WAVE:
			phase_text = "[ WAVE IN PROGRESS ]"
			phase_color = DANGER_COLOR
		GameManager.GamePhase.BETWEEN_WAVES:
			phase_text = "[ WAVE CLEAR — BUILD ]"
			phase_color = ACCENT_COLOR
		GameManager.GamePhase.BOSS:
			phase_text = "[ BOSS WAVE ]"
			phase_color = Color(0.67, 0.27, 1)
		GameManager.GamePhase.GAME_OVER:
			phase_text = "[ GAME OVER ]"
			phase_color = DANGER_COLOR

	var text_size := font.get_string_size(phase_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 16)
	_draw_node.draw_string(font, Vector2((vp_size.x - text_size.x) * 0.5, 22), phase_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 16, phase_color)


func _draw_wave_info(vp_size: Vector2) -> void:
	var font := ThemeDB.fallback_font
	if not font:
		return

	## Enemy count during wave
	if GameManager.current_phase == GameManager.GamePhase.WAVE or \
	   GameManager.current_phase == GameManager.GamePhase.BOSS:
		var enemy_count := get_tree().get_nodes_in_group("enemies").size()
		_draw_node.draw_string(font, Vector2(vp_size.x - 150, 22), "ENEMIES: %d" % enemy_count, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, DANGER_COLOR)
