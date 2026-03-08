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
	{ "id": "data_siphon", "name": "Siphon", "cost": 200, "key": "4", "color": Color(0, 1, 0.53) },
	{ "id": "amplifier", "name": "Amp", "cost": 180, "key": "5", "color": Color(1, 0.87, 0.27) },
	{ "id": "shield_generator", "name": "Shield", "cost": 250, "key": "6", "color": Color(0.67, 0.27, 1) },
]


## ============================================================================
## STATE
## ============================================================================

var selected_tower_index: int = -1
var _info_panel: Control
var _draw_node: Control
var _selected_tower: Node2D = null  # Currently selected placed tower for info


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
			KEY_4:
				_select_tower(3)
			KEY_5:
				_select_tower(4)
			KEY_6:
				_select_tower(5)
			KEY_ESCAPE:
				_select_tower(-1)  # Deselect
				hide_tower_info()
			KEY_U:
				## Upgrade selected tower
				if _selected_tower:
					tower_upgrade_requested.emit()
			KEY_X:
				## Sell selected tower
				if _selected_tower:
					tower_sell_requested.emit()
			KEY_T:
				## Cycle targeting priority on selected tower
				if _selected_tower and "target_priority" in _selected_tower:
					var cur: int = _selected_tower.target_priority
					_selected_tower.target_priority = (cur + 1) % 4
					_draw_node.queue_redraw()
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


## Show info panel for a placed tower.
func show_tower_info(tower: Node2D) -> void:
	_selected_tower = tower
	_draw_node.queue_redraw()


## Hide the tower info panel.
func hide_tower_info() -> void:
	_selected_tower = null
	_draw_node.queue_redraw()


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
	_draw_tower_info_panel(vp_size)


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

	## Tower buttons — compact to fit 6 towers + start wave
	var btn_w := 90.0
	var btn_h := 44.0
	var gap := 6.0
	var start_x := 8.0
	var btn_y := panel_y + 10.0

	for i in TOWER_OPTIONS.size():
		var opt: Dictionary = TOWER_OPTIONS[i]
		var rect := Rect2(start_x + i * (btn_w + gap), btn_y, btn_w, btn_h)

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
		_draw_node.draw_string(font, Vector2(rect.position.x + 4, rect.position.y + 16), "[%s] %s" % [opt["key"], opt["name"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, text_col)
		_draw_node.draw_string(font, Vector2(rect.position.x + 4, rect.position.y + 32), "$%d" % opt["cost"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, text_col * Color(1, 1, 1, 0.7))

	## Start Wave button (during build phase)
	if GameManager.current_phase == GameManager.GamePhase.BUILD or \
	   GameManager.current_phase == GameManager.GamePhase.BETWEEN_WAVES:
		var sw_rect := Rect2(vp_size.x - 160, btn_y, 140, btn_h)
		_draw_node.draw_rect(sw_rect, Color(0, 1, 0.53, 0.1))
		_draw_node.draw_rect(sw_rect, TEXT_COLOR, false, 1.5)
		_draw_node.draw_string(font, Vector2(sw_rect.position.x + 8, sw_rect.position.y + 18), "[SPACE]", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, TEXT_COLOR * Color(1, 1, 1, 0.6))
		_draw_node.draw_string(font, Vector2(sw_rect.position.x + 8, sw_rect.position.y + 34), "START WAVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, TEXT_COLOR)


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


func _draw_tower_info_panel(vp_size: Vector2) -> void:
	if not _selected_tower or not is_instance_valid(_selected_tower):
		_selected_tower = null
		return

	var font := ThemeDB.fallback_font
	if not font:
		return

	## Right-side info panel
	var panel_w := 180.0
	var panel_h := 160.0
	var panel_x := vp_size.x - panel_w - 8
	var panel_y := 40.0
	var rect := Rect2(panel_x, panel_y, panel_w, panel_h)

	_draw_node.draw_rect(rect, PANEL_COLOR)
	_draw_node.draw_rect(rect, BORDER_COLOR, false, 1.0)

	var x := panel_x + 8
	var y := panel_y + 18

	## Tower name
	var t_name: String = _selected_tower.tower_name if "tower_name" in _selected_tower else "Tower"
	var t_color: Color = _selected_tower.tower_color if "tower_color" in _selected_tower else ACCENT_COLOR
	_draw_node.draw_string(font, Vector2(x, y), t_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, t_color)
	y += 18

	## Level
	var t_level: int = _selected_tower.level if "level" in _selected_tower else 1
	_draw_node.draw_string(font, Vector2(x, y), "Level: %d/3" % t_level, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, TEXT_COLOR)
	y += 16

	## Damage (if applicable)
	if "effective_damage" in _selected_tower and _selected_tower.effective_damage > 0:
		_draw_node.draw_string(font, Vector2(x, y), "DMG: %.0f" % _selected_tower.effective_damage, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, TEXT_COLOR)
		y += 14

	## Range
	if "effective_range" in _selected_tower:
		_draw_node.draw_string(font, Vector2(x, y), "RNG: %.1f" % _selected_tower.effective_range, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, TEXT_COLOR)
		y += 14

	## Shield (for Shield Generator)
	if _selected_tower.has_method("absorb_damage") and "current_shield" in _selected_tower:
		_draw_node.draw_string(font, Vector2(x, y), "SHIELD: %d/%d" % [int(_selected_tower.current_shield), _selected_tower.max_shield_hp], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.67, 0.27, 1))
		y += 14

	## Targeting priority (for attack towers)
	if "target_priority" in _selected_tower and "effective_attack_speed" in _selected_tower and _selected_tower.effective_attack_speed > 0:
		var priority_names := ["FIRST", "LAST", "STRONG", "WEAK"]
		var pri: int = _selected_tower.target_priority
		_draw_node.draw_string(font, Vector2(x, y), "[T] Target: %s" % priority_names[pri], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, TEXT_COLOR)
		y += 14

	y += 4

	## Upgrade button
	if t_level < 3:
		var upgrade_cost: int = _selected_tower.get_next_upgrade_cost() if _selected_tower.has_method("get_next_upgrade_cost") else -1
		if upgrade_cost > 0:
			var can_upgrade: bool = GameManager.resources >= upgrade_cost
			var u_col: Color = ACCENT_COLOR if can_upgrade else Color(0.4, 0.4, 0.4)
			_draw_node.draw_string(font, Vector2(x, y), "[U] Upgrade $%d" % upgrade_cost, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, u_col)
			y += 16

	## Sell button
	var sell_val: int = _selected_tower.get_sell_value() if _selected_tower.has_method("get_sell_value") else 0
	_draw_node.draw_string(font, Vector2(x, y), "[X] Sell +$%d" % sell_val, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, WARNING_COLOR)
