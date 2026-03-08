## ============================================================================
## GAME HUD
## ============================================================================
##
## Purpose: In-game heads-up display with diegetic terminal aesthetic.
## Shows core HP, scrap, power pips, wave info, signal charge meter,
## tower selection panel, and selected tower info.
## All drawn via _draw() for the CRT look.
##
## @author Signal Lost Team
## @version 0.2.0
class_name GameHUD
extends CanvasLayer


## ============================================================================
## SIGNALS
## ============================================================================

signal tower_type_selected(tower_id: String)
signal start_wave_pressed()
signal tower_upgrade_requested()
signal tower_sell_requested()
signal branch_selected(branch_id: String)


## ============================================================================
## CONSTANTS
## ============================================================================

const PANEL_COLOR := Color(0.04, 0.06, 0.09, 0.92)
const BORDER_COLOR := Color(0, 1, 0.53, 0.25)
const BORDER_BRIGHT := Color(0, 1, 0.53, 0.5)
const TEXT_COLOR := Color(0, 1, 0.53)  # Terminal green #00FF88
const TEXT_DIM := Color(0, 1, 0.53, 0.5)
const ACCENT_COLOR := Color(0, 0.78, 1)  # Cyan #00C8FF
const WARNING_COLOR := Color(1, 0.73, 0)  # Amber #FFB800
const DANGER_COLOR := Color(1, 0.13, 0.27)  # Red #FF2244
const CHARGE_COLOR := Color(1, 0.72, 0)  # Signal charge amber
const CHARGE_FULL := Color(1, 0.9, 0.3)  # Signal charge when full

## Top bar layout
const TOP_BAR_H := 36.0
## Bottom panel layout
const BOTTOM_PANEL_H := 68.0

const TOWER_OPTIONS := [
	{ "id": "pulse_emitter", "name": "Pulse", "cost": 50, "power": 1, "key": "1", "color": Color(0, 0.78, 1) },
	{ "id": "arc_relay", "name": "Arc", "cost": 70, "power": 1, "key": "2", "color": Color(0.27, 0.53, 1) },
	{ "id": "cryo_node", "name": "Cryo", "cost": 60, "power": 1, "key": "3", "color": Color(0.53, 0.87, 1) },
	{ "id": "scrambler_dish", "name": "Scramble", "cost": 75, "power": 1, "key": "4", "color": Color(0.86, 0.44, 1) },
	{ "id": "prism_beam", "name": "Prism", "cost": 90, "power": 2, "key": "5", "color": Color(1, 0.84, 0) },
	{ "id": "salvage_matrix", "name": "Salvage", "cost": 80, "power": 1, "key": "6", "color": Color(0.2, 0.9, 0.4) },
]


## ============================================================================
## STATE
## ============================================================================

var selected_tower_index: int = -1
var _info_panel: Control
var _draw_node: Control
var _selected_tower: Node2D = null  # Currently selected placed tower for info
var _branch_choices: Array = []  ## Active branch choice options
var _branch_choosing: bool = false  ## Whether we're showing branch choice UI
var _wave_preview: Array = []  ## Incoming enemy types for next wave


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

	GameManager.scrap_changed.connect(func(_v: int): _draw_node.queue_redraw())
	GameManager.power_changed.connect(func(_u: int, _c: int): _draw_node.queue_redraw())
	GameManager.core_hp_changed.connect(func(_v: int): _draw_node.queue_redraw())
	GameManager.wave_started.connect(func(_v: int): _draw_node.queue_redraw())
	GameManager.wave_completed.connect(func(_v: int): _draw_node.queue_redraw())
	GameManager.game_phase_changed.connect(func(_v: GameManager.GamePhase): _draw_node.queue_redraw())
	GameManager.signal_charge_changed.connect(func(_c: float, _m: float): _draw_node.queue_redraw())


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		## Branch choice mode intercepts 1/2 keys
		if _branch_choosing:
			match event.keycode:
				KEY_1:
					if _branch_choices.size() >= 1:
						branch_selected.emit(_branch_choices[0].id)
						_branch_choosing = false
						_branch_choices = []
						_draw_node.queue_redraw()
				KEY_2:
					if _branch_choices.size() >= 2:
						branch_selected.emit(_branch_choices[1].id)
						_branch_choosing = false
						_branch_choices = []
						_draw_node.queue_redraw()
				KEY_ESCAPE:
					_branch_choosing = false
					_branch_choices = []
					_draw_node.queue_redraw()
			return

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
	_branch_choosing = false
	_branch_choices = []
	_draw_node.queue_redraw()


## Hide the tower info panel.
func hide_tower_info() -> void:
	_selected_tower = null
	_branch_choosing = false
	_branch_choices = []
	_draw_node.queue_redraw()


## Set wave preview data (array of { "enemy", "count", "name" }).
func set_wave_preview(preview: Array) -> void:
	_wave_preview = preview
	_draw_node.queue_redraw()


## Show branch choice UI for an upgrade.
func show_branch_choice(branches: Array) -> void:
	_branch_choices = branches
	_branch_choosing = true
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
	_draw_wave_preview(vp_size)
	_draw_tower_info_panel(vp_size)
	_draw_corner_frames(vp_size)
	if _branch_choosing:
		_draw_branch_choice(vp_size)


## ── TOP BAR ──────────────────────────────────────────────────────────────────

func _draw_top_bar(vp_size: Vector2) -> void:
	var font := ThemeDB.fallback_font
	if not font:
		return

	## Background with double border
	_draw_node.draw_rect(Rect2(0, 0, vp_size.x, TOP_BAR_H), PANEL_COLOR)
	_draw_node.draw_line(Vector2(0, TOP_BAR_H), Vector2(vp_size.x, TOP_BAR_H), BORDER_BRIGHT, 1.0)
	_draw_node.draw_line(Vector2(0, TOP_BAR_H + 1), Vector2(vp_size.x, TOP_BAR_H + 1), BORDER_COLOR, 1.0)

	var y_text := 15.0
	var y_bar := 21.0

	## ── CORE HP (bar + text) ──
	var hp_ratio := float(GameManager.core_hp) / GameManager.STARTING_CORE_HP
	var hp_color := TEXT_COLOR
	if hp_ratio < 0.25:
		hp_color = DANGER_COLOR
	elif hp_ratio < 0.5:
		hp_color = WARNING_COLOR

	_draw_node.draw_string(font, Vector2(10, y_text), "CORE", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, TEXT_DIM)
	## HP bar — segmented
	var bar_x := 10.0
	var bar_w := 120.0
	var bar_h := 8.0
	var seg_count := GameManager.STARTING_CORE_HP
	var seg_w := bar_w / seg_count
	for i in seg_count:
		var sx := bar_x + i * seg_w
		var seg_rect := Rect2(sx, y_bar, seg_w - 1, bar_h)
		if i < GameManager.core_hp:
			_draw_node.draw_rect(seg_rect, hp_color)
		else:
			_draw_node.draw_rect(seg_rect, Color(0.15, 0.15, 0.15, 0.6))
	_draw_node.draw_string(font, Vector2(bar_x + bar_w + 4, y_bar + bar_h), "%d/%d" % [GameManager.core_hp, GameManager.STARTING_CORE_HP], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, hp_color)

	## ── SCRAP ──
	var scrap_x := 190.0
	_draw_node.draw_string(font, Vector2(scrap_x, y_text), "SCRAP", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, TEXT_DIM)
	_draw_node.draw_string(font, Vector2(scrap_x, y_bar + bar_h), "%d" % GameManager.scrap, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ACCENT_COLOR)

	## ── POWER (pip display) ──
	var pwr_x := 280.0
	_draw_node.draw_string(font, Vector2(pwr_x, y_text), "POWER", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, TEXT_DIM)
	var pip_size := 8.0
	var pip_gap := 3.0
	for i in GameManager.power_cap:
		var px := pwr_x + i * (pip_size + pip_gap)
		var pip_rect := Rect2(px, y_bar, pip_size, bar_h)
		if i < GameManager.power_used:
			_draw_node.draw_rect(pip_rect, WARNING_COLOR)
		else:
			_draw_node.draw_rect(pip_rect, Color(TEXT_COLOR, 0.2))
			_draw_node.draw_rect(pip_rect, Color(TEXT_COLOR, 0.3), false, 1.0)
	var pwr_label_x := pwr_x + GameManager.power_cap * (pip_size + pip_gap) + 2
	_draw_node.draw_string(font, Vector2(pwr_label_x, y_bar + bar_h), "%d/%d" % [GameManager.power_used, GameManager.power_cap], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, TEXT_DIM)

	## ── WAVE ──
	var wave_x := 430.0
	_draw_node.draw_string(font, Vector2(wave_x, y_text), "WAVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, TEXT_DIM)
	_draw_node.draw_string(font, Vector2(wave_x, y_bar + bar_h), "%d / %d" % [GameManager.current_wave, GameManager.MAX_WAVES], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, TEXT_COLOR)

	## Enemy count during wave (inline after wave number)
	if GameManager.current_phase == GameManager.GamePhase.WAVE or \
	   GameManager.current_phase == GameManager.GamePhase.BOSS:
		var enemy_count := get_tree().get_nodes_in_group("enemies").size()
		_draw_node.draw_string(font, Vector2(wave_x + 60, y_bar + bar_h), "[ %d ACTIVE ]" % enemy_count, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, DANGER_COLOR)

	## ── SIGNAL CHARGE (meter bar) ──
	var sig_x := 600.0
	var sig_w := 140.0
	var charge_ratio := GameManager.signal_charge / GameManager.signal_charge_max
	var sig_color := CHARGE_FULL if charge_ratio >= 1.0 else CHARGE_COLOR

	_draw_node.draw_string(font, Vector2(sig_x, y_text), "SIGNAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, TEXT_DIM)
	## Bar background
	_draw_node.draw_rect(Rect2(sig_x, y_bar, sig_w, bar_h), Color(0.12, 0.12, 0.12, 0.8))
	## Bar fill
	_draw_node.draw_rect(Rect2(sig_x, y_bar, sig_w * charge_ratio, bar_h), sig_color)
	## Bar border
	_draw_node.draw_rect(Rect2(sig_x, y_bar, sig_w, bar_h), Color(sig_color, 0.4), false, 1.0)
	## Percentage
	_draw_node.draw_string(font, Vector2(sig_x + sig_w + 4, y_bar + bar_h), "%d%%" % int(charge_ratio * 100), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, sig_color)

	## ── Vertical separators between sections ──
	var sep_color := Color(BORDER_COLOR, 0.4)
	for sx in [180.0, 270.0, 420.0, 590.0]:
		_draw_node.draw_line(Vector2(sx, 4), Vector2(sx, TOP_BAR_H - 4), sep_color, 1.0)


## ── TOWER SELECTION PANEL ────────────────────────────────────────────────────

func _draw_tower_panel(vp_size: Vector2) -> void:
	var font := ThemeDB.fallback_font
	if not font:
		return

	## Bottom panel
	var panel_y := vp_size.y - BOTTOM_PANEL_H
	_draw_node.draw_rect(Rect2(0, panel_y, vp_size.x, BOTTOM_PANEL_H), PANEL_COLOR)
	_draw_node.draw_line(Vector2(0, panel_y), Vector2(vp_size.x, panel_y), BORDER_BRIGHT, 1.0)
	_draw_node.draw_line(Vector2(0, panel_y - 1), Vector2(vp_size.x, panel_y - 1), BORDER_COLOR, 1.0)

	## Tower buttons
	var btn_w := 92.0
	var btn_h := 48.0
	var gap := 6.0
	var start_x := 10.0
	var btn_y := panel_y + 10.0

	for i in TOWER_OPTIONS.size():
		var opt: Dictionary = TOWER_OPTIONS[i]
		var rect := Rect2(start_x + i * (btn_w + gap), btn_y, btn_w, btn_h)
		var can_afford: bool = GameManager.scrap >= opt["cost"] and GameManager.can_use_power(opt["power"])
		var is_selected: bool = (i == selected_tower_index)

		## Button background
		var bg_color := PANEL_COLOR
		if is_selected:
			bg_color = Color(opt["color"], 0.15)
		_draw_node.draw_rect(rect, bg_color)

		## Color indicator bar (left edge)
		var indicator_rect := Rect2(rect.position.x, rect.position.y, 3, btn_h)
		_draw_node.draw_rect(indicator_rect, opt["color"] if (can_afford or is_selected) else Color(0.3, 0.3, 0.3))

		## Border
		var border_col: Color = opt["color"] if is_selected else BORDER_COLOR
		_draw_node.draw_rect(rect, border_col, false, 1.0 if not is_selected else 1.5)

		## Text
		var text_col: Color = opt["color"] if can_afford else Color(0.35, 0.35, 0.35)
		_draw_node.draw_string(font, Vector2(rect.position.x + 8, rect.position.y + 16), "[%s] %s" % [opt["key"], opt["name"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, text_col)
		## Cost and power on second line
		var cost_col: Color = (ACCENT_COLOR if can_afford else Color(0.3, 0.3, 0.3)) * Color(1, 1, 1, 0.8)
		_draw_node.draw_string(font, Vector2(rect.position.x + 8, rect.position.y + 32), "$%d" % opt["cost"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, cost_col)
		## Power pips
		var pip_start_x := rect.position.x + 40
		for p in opt["power"]:
			var pip_r := Rect2(pip_start_x + p * 8, rect.position.y + 26, 5, 5)
			_draw_node.draw_rect(pip_r, WARNING_COLOR if can_afford else Color(0.3, 0.3, 0.3))

	## Start Wave button (during build phase)
	if GameManager.current_phase == GameManager.GamePhase.BUILD or \
	   GameManager.current_phase == GameManager.GamePhase.BETWEEN_WAVES:
		var sw_w := 150.0
		var sw_rect := Rect2(vp_size.x - sw_w - 10, btn_y, sw_w, btn_h)
		## Pulsing glow background
		var pulse: float = 0.08 + abs(sin(Time.get_ticks_msec() * 0.003)) * 0.07
		_draw_node.draw_rect(sw_rect, Color(0, 1, 0.53, pulse))
		_draw_node.draw_rect(sw_rect, TEXT_COLOR, false, 1.5)
		_draw_node.draw_string(font, Vector2(sw_rect.position.x + 10, sw_rect.position.y + 18), "[SPACE]", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, TEXT_DIM)
		_draw_node.draw_string(font, Vector2(sw_rect.position.x + 10, sw_rect.position.y + 36), "START WAVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, TEXT_COLOR)


## ── PHASE INDICATOR ──────────────────────────────────────────────────────────

func _draw_phase_indicator(vp_size: Vector2) -> void:
	var font := ThemeDB.fallback_font
	if not font:
		return

	var phase_text := ""
	var phase_color := TEXT_COLOR
	match GameManager.current_phase:
		GameManager.GamePhase.BUILD:
			phase_text = "BUILD PHASE"
		GameManager.GamePhase.WAVE:
			phase_text = "WAVE IN PROGRESS"
			phase_color = DANGER_COLOR
		GameManager.GamePhase.BETWEEN_WAVES:
			phase_text = "WAVE CLEAR"
			phase_color = ACCENT_COLOR
		GameManager.GamePhase.REWARD_CHOICE:
			phase_text = "CHOOSE REWARD"
			phase_color = WARNING_COLOR
		GameManager.GamePhase.BOSS:
			phase_text = "BOSS WAVE"
			phase_color = Color(0.67, 0.27, 1)
		GameManager.GamePhase.GAME_OVER:
			phase_text = "GAME OVER"
			phase_color = DANGER_COLOR

	## Terminal-style framing: ═══[ PHASE TEXT ]═══
	var full_text := phase_text
	var text_size := font.get_string_size(full_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 13)
	var cx := vp_size.x * 0.5
	var cy := TOP_BAR_H + 16

	## Decorative lines on either side
	var line_w := 40.0
	var text_half := text_size.x * 0.5
	_draw_node.draw_line(Vector2(cx - text_half - line_w - 8, cy - 4), Vector2(cx - text_half - 8, cy - 4), Color(phase_color, 0.4), 1.0)
	_draw_node.draw_line(Vector2(cx + text_half + 8, cy - 4), Vector2(cx + text_half + line_w + 8, cy - 4), Color(phase_color, 0.4), 1.0)

	## Brackets
	_draw_node.draw_string(font, Vector2(cx - text_half - 6, cy), "[", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(phase_color, 0.6))
	_draw_node.draw_string(font, Vector2(cx + text_half + 1, cy), "]", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(phase_color, 0.6))

	## Phase text
	_draw_node.draw_string(font, Vector2(cx - text_half, cy), full_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, phase_color)


## ── WAVE PREVIEW ────────────────────────────────────────────────────────────

func _draw_wave_preview(vp_size: Vector2) -> void:
	## Only show during build/between-waves phases when we have preview data
	if _wave_preview.is_empty():
		return
	if GameManager.current_phase != GameManager.GamePhase.BUILD and \
	   GameManager.current_phase != GameManager.GamePhase.BETWEEN_WAVES:
		return

	var font := ThemeDB.fallback_font
	if not font:
		return

	## Position below phase indicator, centered
	var y_start := TOP_BAR_H + 32.0
	var cx := vp_size.x * 0.5

	## Calculate total width for centering
	var entry_w := 80.0
	var entry_gap := 6.0
	var total_w := _wave_preview.size() * entry_w + (_wave_preview.size() - 1) * entry_gap
	var start_x := cx - total_w * 0.5

	## Label
	var label := "INCOMING"
	var label_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, 9)
	_draw_node.draw_string(font, Vector2(cx - label_size.x * 0.5, y_start), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, TEXT_DIM)
	y_start += 10.0

	## Draw each enemy type as a compact badge
	for i in _wave_preview.size():
		var entry: Dictionary = _wave_preview[i]
		var name_str: String = entry.get("name", "???")
		var count: int = entry.get("count", 0)
		var ex := start_x + i * (entry_w + entry_gap)
		var badge_rect := Rect2(ex, y_start, entry_w, 18)

		## Badge background
		_draw_node.draw_rect(badge_rect, Color(DANGER_COLOR, 0.08))
		_draw_node.draw_rect(badge_rect, Color(DANGER_COLOR, 0.25), false, 1.0)

		## Enemy name + count
		var badge_text := "%s x%d" % [name_str, count]
		_draw_node.draw_string(font, Vector2(ex + 4, y_start + 13), badge_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(DANGER_COLOR, 0.8))


## ── TOWER INFO PANEL ─────────────────────────────────────────────────────────

func _draw_tower_info_panel(vp_size: Vector2) -> void:
	if not _selected_tower or not is_instance_valid(_selected_tower):
		_selected_tower = null
		return

	var font := ThemeDB.fallback_font
	if not font:
		return

	## Right-side info panel
	var panel_w := 190.0
	var panel_h := 180.0
	var panel_x := vp_size.x - panel_w - 8
	var panel_y := TOP_BAR_H + 8
	var rect := Rect2(panel_x, panel_y, panel_w, panel_h)

	_draw_node.draw_rect(rect, PANEL_COLOR)
	_draw_node.draw_rect(rect, BORDER_BRIGHT, false, 1.0)

	var x := panel_x + 10
	var y := panel_y + 18

	## Tower name with color indicator
	var t_name: String = _selected_tower.tower_name if "tower_name" in _selected_tower else "Tower"
	var t_color: Color = _selected_tower.tower_color if "tower_color" in _selected_tower else ACCENT_COLOR
	## Color pip before name
	_draw_node.draw_rect(Rect2(x, y - 8, 4, 12), t_color)
	_draw_node.draw_string(font, Vector2(x + 10, y), t_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, t_color)
	y += 16

	## Level + branch name
	var t_level: int = _selected_tower.level if "level" in _selected_tower else 1
	var branch_name: String = _selected_tower.get_branch_name() if _selected_tower.has_method("get_branch_name") else ""
	if branch_name != "":
		_draw_node.draw_string(font, Vector2(x + 10, y), "Lv%d — %s" % [t_level, branch_name], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, TEXT_DIM)
	else:
		_draw_node.draw_string(font, Vector2(x + 10, y), "Level %d / 3" % t_level, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, TEXT_DIM)
	y += 14

	## Separator line
	_draw_node.draw_line(Vector2(x, y), Vector2(panel_x + panel_w - 10, y), BORDER_COLOR, 1.0)
	y += 8

	## Stats section
	if "effective_damage" in _selected_tower and _selected_tower.effective_damage > 0:
		_draw_node.draw_string(font, Vector2(x, y), "DMG", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, TEXT_DIM)
		_draw_node.draw_string(font, Vector2(x + 50, y), "%.0f" % _selected_tower.effective_damage, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, TEXT_COLOR)
		y += 13

	if "effective_attack_speed" in _selected_tower and _selected_tower.effective_attack_speed > 0:
		_draw_node.draw_string(font, Vector2(x, y), "SPD", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, TEXT_DIM)
		_draw_node.draw_string(font, Vector2(x + 50, y), "%.1f/s" % _selected_tower.effective_attack_speed, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, TEXT_COLOR)
		y += 13

	if "effective_range" in _selected_tower:
		_draw_node.draw_string(font, Vector2(x, y), "RNG", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, TEXT_DIM)
		_draw_node.draw_string(font, Vector2(x + 50, y), "%.1f" % _selected_tower.effective_range, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, TEXT_COLOR)
		y += 13

	## Targeting priority (for attack towers)
	if "target_priority" in _selected_tower and "effective_attack_speed" in _selected_tower and _selected_tower.effective_attack_speed > 0:
		var priority_names := ["FIRST", "LAST", "STRONG", "WEAK"]
		var pri: int = _selected_tower.target_priority
		y += 2
		_draw_node.draw_string(font, Vector2(x, y), "[T] %s" % priority_names[pri], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, TEXT_DIM)
		y += 13

	## Separator line
	y += 2
	_draw_node.draw_line(Vector2(x, y), Vector2(panel_x + panel_w - 10, y), BORDER_COLOR, 1.0)
	y += 8

	## Upgrade button
	if t_level < 3:
		var upgrade_cost: int = _selected_tower.get_next_upgrade_cost() if _selected_tower.has_method("get_next_upgrade_cost") else -1
		if upgrade_cost > 0:
			var can_upgrade: bool = GameManager.scrap >= upgrade_cost
			var u_col: Color = ACCENT_COLOR if can_upgrade else Color(0.35, 0.35, 0.35)
			_draw_node.draw_string(font, Vector2(x, y), "[U] UPGRADE", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, u_col)
			_draw_node.draw_string(font, Vector2(x + 90, y), "$%d" % upgrade_cost, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, u_col)
			y += 16

	## Sell button
	var sell_val: int = _selected_tower.get_sell_value() if _selected_tower.has_method("get_sell_value") else 0
	_draw_node.draw_string(font, Vector2(x, y), "[X] SELL", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, WARNING_COLOR)
	_draw_node.draw_string(font, Vector2(x + 90, y), "+$%d" % sell_val, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, WARNING_COLOR)


## ── CORNER FRAMES ────────────────────────────────────────────────────────────

func _draw_corner_frames(vp_size: Vector2) -> void:
	## Subtle terminal corner decorations
	var corner_len := 12.0
	var col := Color(BORDER_COLOR, 0.5)
	var inset := 2.0
	var bottom_y := vp_size.y - BOTTOM_PANEL_H

	## Top-left (below top bar)
	var tl_y := TOP_BAR_H + 4
	_draw_node.draw_line(Vector2(inset, tl_y), Vector2(inset + corner_len, tl_y), col, 1.0)
	_draw_node.draw_line(Vector2(inset, tl_y), Vector2(inset, tl_y + corner_len), col, 1.0)

	## Top-right (below top bar)
	_draw_node.draw_line(Vector2(vp_size.x - inset, tl_y), Vector2(vp_size.x - inset - corner_len, tl_y), col, 1.0)
	_draw_node.draw_line(Vector2(vp_size.x - inset, tl_y), Vector2(vp_size.x - inset, tl_y + corner_len), col, 1.0)

	## Bottom-left (above bottom panel)
	_draw_node.draw_line(Vector2(inset, bottom_y - 4), Vector2(inset + corner_len, bottom_y - 4), col, 1.0)
	_draw_node.draw_line(Vector2(inset, bottom_y - 4), Vector2(inset, bottom_y - 4 - corner_len), col, 1.0)

	## Bottom-right (above bottom panel)
	_draw_node.draw_line(Vector2(vp_size.x - inset, bottom_y - 4), Vector2(vp_size.x - inset - corner_len, bottom_y - 4), col, 1.0)
	_draw_node.draw_line(Vector2(vp_size.x - inset, bottom_y - 4), Vector2(vp_size.x - inset, bottom_y - 4 - corner_len), col, 1.0)


## ── BRANCH CHOICE OVERLAY ────────────────────────────────────────────────────

func _draw_branch_choice(vp_size: Vector2) -> void:
	var font := ThemeDB.fallback_font
	if not font or _branch_choices.is_empty():
		return

	## Semi-transparent overlay
	_draw_node.draw_rect(Rect2(Vector2.ZERO, vp_size), Color(0, 0, 0, 0.4))

	## Center panel
	var panel_w := 340.0
	var panel_h := 190.0
	var panel_x := (vp_size.x - panel_w) * 0.5
	var panel_y := (vp_size.y - panel_h) * 0.5 - 30
	var panel_rect := Rect2(panel_x, panel_y, panel_w, panel_h)

	_draw_node.draw_rect(panel_rect, PANEL_COLOR)
	_draw_node.draw_rect(panel_rect, BORDER_BRIGHT, false, 1.5)

	var x := panel_x + 16
	var y := panel_y + 24

	## Title
	_draw_node.draw_string(font, Vector2(x, y), "CHOOSE UPGRADE PATH", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ACCENT_COLOR)
	y += 6
	_draw_node.draw_line(Vector2(x, y), Vector2(panel_x + panel_w - 16, y), BORDER_COLOR, 1.0)
	y += 16

	## Draw each branch option
	for i in _branch_choices.size():
		var branch: Dictionary = _branch_choices[i]
		var key := str(i + 1)
		var cost: int = branch.get("cost", 0)
		var can_afford: bool = GameManager.scrap >= cost
		var name_col: Color = ACCENT_COLOR if can_afford else Color(0.35, 0.35, 0.35)
		var desc_col: Color = TEXT_COLOR if can_afford else Color(0.25, 0.25, 0.25)

		## Option box
		var opt_rect := Rect2(x, y - 10, panel_w - 32, 52)
		_draw_node.draw_rect(opt_rect, Color(ACCENT_COLOR, 0.04))
		_draw_node.draw_rect(opt_rect, Color(ACCENT_COLOR, 0.2), false, 1.0)

		## [1] Branch Name — $cost
		_draw_node.draw_string(font, Vector2(x + 8, y + 6), "[%s] %s — $%d" % [key, branch.get("name", "???"), cost], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, name_col)
		## Description
		_draw_node.draw_string(font, Vector2(x + 8, y + 24), branch.get("description", ""), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, desc_col)

		y += 60

	## ESC to cancel
	_draw_node.draw_string(font, Vector2(x, y + 4), "[ESC] Cancel", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.4, 0.4, 0.4))
