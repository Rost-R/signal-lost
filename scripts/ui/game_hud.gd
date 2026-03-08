## ============================================================================
## GAME HUD
## ============================================================================
##
## Purpose: In-game heads-up display. Shows core HP, scrap, power, wave info,
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
signal branch_selected(branch_id: String)


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
	_draw_wave_info(vp_size)
	_draw_tower_info_panel(vp_size)
	if _branch_choosing:
		_draw_branch_choice(vp_size)


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

	## Scrap
	_draw_node.draw_string(font, Vector2(220, 22), "SCRAP: %d" % GameManager.scrap, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ACCENT_COLOR)

	## Power
	var pwr_color := TEXT_COLOR
	if GameManager.power_used >= GameManager.power_cap:
		pwr_color = WARNING_COLOR
	_draw_node.draw_string(font, Vector2(380, 22), "PWR: %d/%d" % [GameManager.power_used, GameManager.power_cap], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, pwr_color)

	## Wave
	_draw_node.draw_string(font, Vector2(530, 22), "WAVE: %d/%d" % [GameManager.current_wave, GameManager.MAX_WAVES], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, TEXT_COLOR)

	## Signal Charge meter
	var charge_x := 680.0
	var charge_w := 120.0
	var charge_h := 10.0
	var charge_y := 11.0
	var charge_ratio := GameManager.signal_charge / GameManager.signal_charge_max
	## Background
	_draw_node.draw_rect(Rect2(charge_x, charge_y, charge_w, charge_h), Color(0.15, 0.15, 0.15, 0.8))
	## Fill — amber/gold color
	var charge_color := Color(1, 0.72, 0)
	if charge_ratio >= 1.0:
		charge_color = Color(1, 0.9, 0.3)  ## Bright when full
	_draw_node.draw_rect(Rect2(charge_x, charge_y, charge_w * charge_ratio, charge_h), charge_color)
	## Border
	_draw_node.draw_rect(Rect2(charge_x, charge_y, charge_w, charge_h), BORDER_COLOR, false, 1.0)
	## Label
	_draw_node.draw_string(font, Vector2(charge_x, charge_y + charge_h + 14), "SIG: %d%%" % int(charge_ratio * 100), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, charge_color)


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
		var can_afford: bool = GameManager.scrap >= opt["cost"] and GameManager.can_use_power(opt["power"])
		var text_col: Color = opt["color"] if can_afford else Color(0.4, 0.4, 0.4)
		_draw_node.draw_string(font, Vector2(rect.position.x + 4, rect.position.y + 16), "[%s] %s" % [opt["key"], opt["name"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, text_col)
		_draw_node.draw_string(font, Vector2(rect.position.x + 4, rect.position.y + 32), "$%d P%d" % [opt["cost"], opt["power"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, text_col * Color(1, 1, 1, 0.7))

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
		GameManager.GamePhase.REWARD_CHOICE:
			phase_text = "[ CHOOSE REWARD ]"
			phase_color = Color(1, 0.72, 0)  # Amber
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

	## Level + branch name
	var t_level: int = _selected_tower.level if "level" in _selected_tower else 1
	var branch_name: String = _selected_tower.get_branch_name() if _selected_tower.has_method("get_branch_name") else ""
	if branch_name != "":
		_draw_node.draw_string(font, Vector2(x, y), "Lv%d — %s" % [t_level, branch_name], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, TEXT_COLOR)
	else:
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
			var can_upgrade: bool = GameManager.scrap >= upgrade_cost
			var u_col: Color = ACCENT_COLOR if can_upgrade else Color(0.4, 0.4, 0.4)
			_draw_node.draw_string(font, Vector2(x, y), "[U] Upgrade $%d" % upgrade_cost, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, u_col)
			y += 16

	## Sell button
	var sell_val: int = _selected_tower.get_sell_value() if _selected_tower.has_method("get_sell_value") else 0
	_draw_node.draw_string(font, Vector2(x, y), "[X] Sell +$%d" % sell_val, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, WARNING_COLOR)


func _draw_branch_choice(vp_size: Vector2) -> void:
	var font := ThemeDB.fallback_font
	if not font or _branch_choices.is_empty():
		return

	## Semi-transparent overlay behind branch panel
	_draw_node.draw_rect(Rect2(Vector2.ZERO, vp_size), Color(0, 0, 0, 0.3))

	## Center panel
	var panel_w := 320.0
	var panel_h := 180.0
	var panel_x := (vp_size.x - panel_w) * 0.5
	var panel_y := (vp_size.y - panel_h) * 0.5 - 30
	var panel_rect := Rect2(panel_x, panel_y, panel_w, panel_h)

	_draw_node.draw_rect(panel_rect, PANEL_COLOR)
	_draw_node.draw_rect(panel_rect, Color(0, 1, 0.53, 0.5), false, 1.5)

	var x := panel_x + 16
	var y := panel_y + 24

	## Title
	_draw_node.draw_string(font, Vector2(x, y), "CHOOSE UPGRADE PATH", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ACCENT_COLOR)
	y += 24

	## Draw each branch option
	for i in _branch_choices.size():
		var branch: Dictionary = _branch_choices[i]
		var key := str(i + 1)
		var cost: int = branch.get("cost", 0)
		var can_afford: bool = GameManager.scrap >= cost
		var name_col: Color = ACCENT_COLOR if can_afford else Color(0.4, 0.4, 0.4)
		var desc_col: Color = TEXT_COLOR if can_afford else Color(0.3, 0.3, 0.3)

		## Option box
		var opt_rect := Rect2(x, y - 12, panel_w - 32, 52)
		_draw_node.draw_rect(opt_rect, Color(ACCENT_COLOR, 0.05))
		_draw_node.draw_rect(opt_rect, Color(ACCENT_COLOR, 0.2), false, 1.0)

		## [1] Branch Name — $cost
		_draw_node.draw_string(font, Vector2(x + 8, y + 4), "[%s] %s — $%d" % [key, branch.get("name", "???"), cost], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, name_col)
		## Description
		_draw_node.draw_string(font, Vector2(x + 8, y + 22), branch.get("description", ""), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, desc_col)

		y += 60

	## ESC to cancel
	_draw_node.draw_string(font, Vector2(x, y + 4), "[ESC] Cancel", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.5, 0.5, 0.5))
