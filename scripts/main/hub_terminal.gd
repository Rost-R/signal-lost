## ============================================================================
## HUB TERMINAL
## ============================================================================
##
## Purpose: Main hub menu between runs. Terminal/CRT aesthetic.
## 7 sections: Start Run, Decode Archive, Upgrade Network,
## Dossiers, Contracts, Settings, Stats.
## All rendered via _draw().
##
## @author Signal Lost Team
## @version 0.1.0
extends Control

const GridManagerScript = preload("res://scripts/systems/grid_manager.gd")


## ============================================================================
## CONSTANTS
## ============================================================================

const BG_COLOR := Color(0.039, 0.055, 0.09)
const GREEN := Color(0, 1, 0.53)
const DIM_GREEN := Color(0, 1, 0.53, 0.5)
const CYAN := Color(0, 0.78, 1)
const AMBER := Color(1, 0.72, 0)
const RED := Color(1, 0.13, 0.27)
const PANEL_BG := Color(0.07, 0.09, 0.14, 0.95)
const BORDER := Color(0, 1, 0.53, 0.3)

enum Screen { MAIN, START_RUN, ARCHIVE, UPGRADES, DOSSIERS, CONTRACTS, SETTINGS, STATS }

## Menu items for main screen
const MENU_ITEMS := [
	{ "label": "START RUN", "key": "1", "screen": Screen.START_RUN, "color_override": "" },
	{ "label": "DECODE ARCHIVE", "key": "2", "screen": Screen.ARCHIVE, "color_override": "" },
	{ "label": "UPGRADE NETWORK", "key": "3", "screen": Screen.UPGRADES, "color_override": "" },
	{ "label": "CREW DOSSIERS", "key": "4", "screen": Screen.DOSSIERS, "color_override": "" },
	{ "label": "CONTRACTS", "key": "5", "screen": Screen.CONTRACTS, "color_override": "" },
	{ "label": "SETTINGS", "key": "6", "screen": Screen.SETTINGS, "color_override": "" },
	{ "label": "RUN STATS", "key": "7", "screen": Screen.STATS, "color_override": "" },
]

## Available sectors loaded from GridManager
var _sector_list: Array[String] = []
var _sector_data: Dictionary = {}

## Difficulty modes
const DIFFICULTY_MODES := [
	{ "id": "standard", "name": "STANDARD", "desc": "Normal difficulty. 10 waves, standard enemy scaling." },
	{ "id": "hard_signal", "name": "HARD SIGNAL", "desc": "Enemies have +30% HP and +20% speed. Reduced scrap rewards." },
	{ "id": "anomaly", "name": "ANOMALY PROTOCOL", "desc": "Randomized modifiers each wave. Unpredictable chaos." },
]

## Tower unlock costs (tower_id -> decoded_transmissions cost)
const TOWER_UNLOCK_COSTS := {
	"scrambler_dish": 15,
	"prism_beam": 25,
	"salvage_matrix": 20,
}


## ============================================================================
## STATE
## ============================================================================

var _current_screen: Screen = Screen.MAIN
var _hovered_item: int = -1
var _selected_sector: int = 0
var _selected_difficulty: int = 0

## Sector grid manager (for reading sector data)
var _grid_temp: Node2D = null


## ============================================================================
## LIFECYCLE
## ============================================================================

func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_STOP
	_load_sector_info()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var vp := get_viewport_rect().size
	var font := ThemeDB.fallback_font
	if not font:
		return

	## Background
	draw_rect(Rect2(Vector2.ZERO, vp), BG_COLOR)

	match _current_screen:
		Screen.MAIN: _draw_main(vp, font)
		Screen.START_RUN: _draw_start_run(vp, font)
		Screen.ARCHIVE: _draw_archive(vp, font)
		Screen.UPGRADES: _draw_upgrades(vp, font)
		Screen.DOSSIERS: _draw_dossiers(vp, font)
		Screen.CONTRACTS: _draw_contracts(vp, font)
		Screen.SETTINGS: _draw_settings(vp, font)
		Screen.STATS: _draw_stats(vp, font)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed):
		return

	match _current_screen:
		Screen.MAIN: _input_main(event)
		Screen.START_RUN: _input_start_run(event)
		Screen.ARCHIVE: _input_sub(event)
		Screen.UPGRADES: _input_upgrades(event)
		Screen.DOSSIERS: _input_sub(event)
		Screen.CONTRACTS: _input_sub(event)
		Screen.SETTINGS: _input_sub(event)
		Screen.STATS: _input_sub(event)


## ============================================================================
## MAIN SCREEN
## ============================================================================

func _draw_main(vp: Vector2, font: Font) -> void:
	## Title
	var title := "SIGNAL LOST"
	var title_size := font.get_string_size(title, HORIZONTAL_ALIGNMENT_CENTER, -1, 28)
	draw_string(font, Vector2((vp.x - title_size.x) * 0.5, 80), title, HORIZONTAL_ALIGNMENT_CENTER, -1, 28, GREEN)

	## Subtitle
	var sub := "RELAY STATION HUB TERMINAL"
	var sub_size := font.get_string_size(sub, HORIZONTAL_ALIGNMENT_CENTER, -1, 12)
	draw_string(font, Vector2((vp.x - sub_size.x) * 0.5, 102), sub, HORIZONTAL_ALIGNMENT_CENTER, -1, 12, DIM_GREEN)

	## Currency display
	var currency_text := "DECODED FRAGMENTS: %d" % MetaManager.decoded_transmissions
	draw_string(font, Vector2(vp.x - 240, 36), currency_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, AMBER)

	## Menu items
	var menu_x: float = (vp.x - 280) * 0.5
	var menu_y: float = 160.0
	var item_h: float = 36.0

	for i in MENU_ITEMS.size():
		var item: Dictionary = MENU_ITEMS[i]
		var item_rect := Rect2(menu_x, menu_y + i * item_h, 280, item_h - 4)

		## Hover background
		if _hovered_item == i:
			draw_rect(item_rect, Color(GREEN.r, GREEN.g, GREEN.b, 0.08))
			draw_rect(item_rect, Color(GREEN, 0.3), false, 1.0)

		var label := "[%s] %s" % [item["key"], item["label"]]
		var color := GREEN if _hovered_item == i else DIM_GREEN
		draw_string(font, Vector2(menu_x + 12, menu_y + i * item_h + 22), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, color)

	## Footer
	draw_string(font, Vector2(12, vp.y - 12), "[ESC] Quit", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, DIM_GREEN)
	draw_string(font, Vector2(vp.x - 100, vp.y - 12), "v0.3.0", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, DIM_GREEN)

	## Blinking cursor
	if int(Time.get_ticks_msec() / 500) % 2 == 0:
		var cursor_y: float = menu_y + MENU_ITEMS.size() * item_h + 20
		draw_string(font, Vector2(menu_x + 12, cursor_y), "_", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, GREEN)


func _input_main(event: InputEvent) -> void:
	match event.keycode:
		KEY_1: _current_screen = Screen.START_RUN
		KEY_2: _current_screen = Screen.ARCHIVE
		KEY_3: _current_screen = Screen.UPGRADES
		KEY_4: _current_screen = Screen.DOSSIERS
		KEY_5: _current_screen = Screen.CONTRACTS
		KEY_6: _current_screen = Screen.SETTINGS
		KEY_7: _current_screen = Screen.STATS
		KEY_ESCAPE: get_tree().quit()
		KEY_ENTER, KEY_KP_ENTER: _current_screen = Screen.START_RUN


## ============================================================================
## START RUN SCREEN
## ============================================================================

func _draw_start_run(vp: Vector2, font: Font) -> void:
	_draw_sub_header(vp, font, "START NEW RUN")

	var x: float = 60.0
	var y: float = 120.0

	## Sector selection
	draw_string(font, Vector2(x, y), "SELECT SECTOR:", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, GREEN)
	y += 24

	for i in _sector_list.size():
		var sid: String = _sector_list[i]
		var info: Dictionary = _sector_data.get(sid, {})
		var name: String = info.get("name", sid)
		var selected := i == _selected_sector
		var prefix := "> " if selected else "  "
		var color := GREEN if selected else DIM_GREEN
		draw_string(font, Vector2(x + 12, y), prefix + name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, color)

		if selected:
			## Show sector description
			var desc: String = info.get("description", "")
			var diff: String = info.get("difficulty", "")
			draw_string(font, Vector2(x + 300, y), diff, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, AMBER)
			if desc != "":
				draw_string(font, Vector2(x + 300, y + 16), desc, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(GREEN, 0.6))
		y += 22

	y += 20

	## Difficulty selection
	draw_string(font, Vector2(x, y), "DIFFICULTY:", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, GREEN)
	y += 24

	for i in DIFFICULTY_MODES.size():
		var mode: Dictionary = DIFFICULTY_MODES[i]
		var selected := i == _selected_difficulty
		var prefix := "> " if selected else "  "
		var color := GREEN if selected else DIM_GREEN
		if i == 1: color = AMBER if selected else Color(AMBER, 0.5)
		if i == 2: color = RED if selected else Color(RED, 0.5)
		draw_string(font, Vector2(x + 12, y), prefix + mode["name"], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, color)

		if selected:
			draw_string(font, Vector2(x + 300, y), mode["desc"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(GREEN, 0.6))
		y += 22

	y += 30

	## Unlocked towers display
	draw_string(font, Vector2(x, y), "AVAILABLE TOWERS:", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, GREEN)
	y += 20
	var tower_names := {
		"pulse_emitter": "Pulse Emitter",
		"arc_relay": "Arc Relay",
		"cryo_node": "Cryo Node",
		"scrambler_dish": "Scrambler Dish",
		"prism_beam": "Prism Beam",
		"salvage_matrix": "Salvage Matrix",
	}
	for tid in tower_names.keys():
		var unlocked := MetaManager.is_tower_unlocked(tid)
		var icon := "[+]" if unlocked else "[?]"
		var tname: String = tower_names[tid] if unlocked else "???"
		var color := GREEN if unlocked else Color(0.3, 0.3, 0.3)
		draw_string(font, Vector2(x + 16, y), "%s %s" % [icon, tname], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, color)
		y += 16

	## Launch button
	y += 20
	draw_string(font, Vector2(x, y), "[ENTER] LAUNCH RUN", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, GREEN)

	## Footer
	draw_string(font, Vector2(12, vp.y - 12), "[ESC] Back", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, DIM_GREEN)


func _input_start_run(event: InputEvent) -> void:
	match event.keycode:
		KEY_ESCAPE:
			_current_screen = Screen.MAIN
		KEY_UP:
			_selected_sector = max(0, _selected_sector - 1)
		KEY_DOWN:
			_selected_sector = min(_sector_list.size() - 1, _selected_sector + 1)
		KEY_LEFT:
			_selected_difficulty = max(0, _selected_difficulty - 1)
		KEY_RIGHT:
			_selected_difficulty = min(DIFFICULTY_MODES.size() - 1, _selected_difficulty + 1)
		KEY_ENTER, KEY_KP_ENTER:
			_launch_run()


func _launch_run() -> void:
	## Store selected sector in RunManager
	var sector: String = _sector_list[_selected_sector] if _selected_sector < _sector_list.size() else "relay_spine"
	RunManager.sector_id = sector

	## Load game scene
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")


## ============================================================================
## ARCHIVE SCREEN (Decode Archive — transmissions read)
## ============================================================================

func _draw_archive(vp: Vector2, font: Font) -> void:
	_draw_sub_header(vp, font, "DECODE ARCHIVE")

	var x: float = 60.0
	var y: float = 120.0

	var unlocked := MetaManager.unlocked_transmissions
	draw_string(font, Vector2(x, y), "TRANSMISSIONS DECODED: %d" % unlocked.size(), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, GREEN)
	y += 28

	if unlocked.is_empty():
		draw_string(font, Vector2(x, y), "No transmissions decoded yet.", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, DIM_GREEN)
		draw_string(font, Vector2(x, y + 20), "Complete runs to discover story fragments.", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(GREEN, 0.4))
	else:
		var col := 0
		var row := 0
		for tx_id in unlocked:
			var tx_x: float = x + col * 200
			var tx_y: float = y + row * 18
			draw_string(font, Vector2(tx_x, tx_y), tx_id, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, CYAN)
			col += 1
			if col >= 4:
				col = 0
				row += 1

	draw_string(font, Vector2(12, vp.y - 12), "[ESC] Back", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, DIM_GREEN)


## ============================================================================
## UPGRADES SCREEN (Tower Unlocks)
## ============================================================================

func _draw_upgrades(vp: Vector2, font: Font) -> void:
	_draw_sub_header(vp, font, "UPGRADE NETWORK")

	var x: float = 60.0
	var y: float = 120.0

	draw_string(font, Vector2(x, y), "DECODED FRAGMENTS: %d" % MetaManager.decoded_transmissions, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, AMBER)
	y += 32

	draw_string(font, Vector2(x, y), "TOWER BLUEPRINTS:", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, GREEN)
	y += 24

	var idx := 1
	for tower_id in TOWER_UNLOCK_COSTS.keys():
		var cost: int = TOWER_UNLOCK_COSTS[tower_id]
		var unlocked := MetaManager.is_tower_unlocked(tower_id)
		var name: String = tower_id.replace("_", " ").capitalize()

		if unlocked:
			draw_string(font, Vector2(x + 12, y), "[UNLOCKED] %s" % name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, GREEN)
		else:
			var can_afford := MetaManager.decoded_transmissions >= cost
			var color := CYAN if can_afford else Color(0.4, 0.4, 0.4)
			draw_string(font, Vector2(x + 12, y), "[%d] %s — %d Fragments" % [idx, name, cost], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, color)
		y += 22
		idx += 1

	y += 16
	draw_string(font, Vector2(x, y), "Press number key to unlock. Fragments earned from runs.", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(GREEN, 0.4))

	draw_string(font, Vector2(12, vp.y - 12), "[ESC] Back", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, DIM_GREEN)


func _input_upgrades(event: InputEvent) -> void:
	if event.keycode == KEY_ESCAPE:
		_current_screen = Screen.MAIN
		return

	## Number keys to unlock towers
	var unlock_keys := TOWER_UNLOCK_COSTS.keys()
	var key_num := -1
	match event.keycode:
		KEY_1: key_num = 0
		KEY_2: key_num = 1
		KEY_3: key_num = 2

	if key_num >= 0 and key_num < unlock_keys.size():
		var tower_id: String = unlock_keys[key_num]
		var cost: int = TOWER_UNLOCK_COSTS[tower_id]
		if not MetaManager.is_tower_unlocked(tower_id) and MetaManager.decoded_transmissions >= cost:
			MetaManager.decoded_transmissions -= cost
			MetaManager.unlock_tower(tower_id)


## ============================================================================
## DOSSIERS SCREEN
## ============================================================================

func _draw_dossiers(vp: Vector2, font: Font) -> void:
	_draw_sub_header(vp, font, "CREW DOSSIERS")

	var x: float = 60.0
	var y: float = 120.0

	var crew := [
		{ "name": "LT. ELENA VASQUEZ", "role": "Commanding Officer", "status": "Active" },
		{ "name": "DR. LIAN CHEN", "role": "Chief Scientist", "status": "Active" },
		{ "name": "SGT. JAMES MERCER", "role": "Security Chief", "status": "Active" },
		{ "name": "ANNA KOWALSKI", "role": "Chief Engineer", "status": "Active" },
		{ "name": "DR. ADAEZE OKAFOR", "role": "Medical Officer", "status": "Active" },
	]

	for member in crew:
		## Name
		draw_string(font, Vector2(x, y), member["name"], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, GREEN)
		## Role
		draw_string(font, Vector2(x + 280, y), member["role"], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, CYAN)
		## Status
		draw_string(font, Vector2(x + 480, y), member["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, AMBER)
		y += 28

	y += 16
	draw_string(font, Vector2(x, y), "Dossier details unlock as you decode transmissions.", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(GREEN, 0.4))

	draw_string(font, Vector2(12, vp.y - 12), "[ESC] Back", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, DIM_GREEN)


## ============================================================================
## CONTRACTS SCREEN
## ============================================================================

func _draw_contracts(vp: Vector2, font: Font) -> void:
	_draw_sub_header(vp, font, "CONTRACTS")

	var x: float = 60.0
	var y: float = 120.0

	draw_string(font, Vector2(x, y), "DAILY CHALLENGE:", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, GREEN)
	y += 24

	## Generate a pseudo-daily seed based on date
	var date := Time.get_date_dict_from_system()
	var daily_seed: int = date.get("year", 2026) * 10000 + date.get("month", 1) * 100 + date.get("day", 1)
	draw_string(font, Vector2(x + 16, y), "Seed: %d" % daily_seed, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, CYAN)
	y += 18
	draw_string(font, Vector2(x + 16, y), "Same seed for all players today. Compare your score!", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, DIM_GREEN)
	y += 28
	draw_string(font, Vector2(x + 16, y), "[ENTER] Start Daily Challenge", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, GREEN)

	y += 40
	draw_string(font, Vector2(x, y), "BOUNTIES:", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, GREEN)
	y += 24
	var bounties := [
		"Survive 5 waves without losing core HP — 10 Fragments",
		"Defeat 100 enemies in a single run — 8 Fragments",
		"Win using only 3 tower types — 15 Fragments",
	]
	for b in bounties:
		draw_string(font, Vector2(x + 16, y), "- " + b, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, DIM_GREEN)
		y += 18

	draw_string(font, Vector2(12, vp.y - 12), "[ESC] Back", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, DIM_GREEN)


## ============================================================================
## SETTINGS SCREEN
## ============================================================================

func _draw_settings(vp: Vector2, font: Font) -> void:
	_draw_sub_header(vp, font, "SETTINGS")

	var x: float = 60.0
	var y: float = 120.0

	var settings := [
		["Master Volume", "100%"],
		["Music Volume", "80%"],
		["SFX Volume", "100%"],
		["CRT Effect", "ON"],
		["Screen Shake", "ON"],
		["Fullscreen", "OFF"],
	]

	for s in settings:
		draw_string(font, Vector2(x, y), s[0], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, GREEN)
		draw_string(font, Vector2(x + 300, y), s[1], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, CYAN)
		y += 24

	y += 20
	draw_string(font, Vector2(x, y), "Settings are saved automatically.", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(GREEN, 0.4))
	y += 20
	draw_string(font, Vector2(x, y), "[D] Delete Save Data", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, RED)

	draw_string(font, Vector2(12, vp.y - 12), "[ESC] Back", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, DIM_GREEN)


## ============================================================================
## STATS SCREEN
## ============================================================================

func _draw_stats(vp: Vector2, font: Font) -> void:
	_draw_sub_header(vp, font, "RUN STATISTICS")

	var x: float = 60.0
	var y: float = 120.0

	var stats := [
		["Total Runs", str(MetaManager.total_runs)],
		["Victories", str(MetaManager.total_wins)],
		["Win Rate", "%d%%" % (int(float(MetaManager.total_wins) / maxf(MetaManager.total_runs, 1) * 100))],
		["Best Wave", str(MetaManager.best_wave)],
		["Towers Unlocked", "%d / 6" % MetaManager.unlocked_towers.size()],
		["Transmissions Decoded", "%d" % MetaManager.unlocked_transmissions.size()],
		["Synergies Discovered", "%d" % MetaManager.discovered_synergies.size()],
		["Decoded Fragments", str(MetaManager.decoded_transmissions)],
	]

	for s in stats:
		draw_string(font, Vector2(x, y), s[0], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, GREEN)
		draw_string(font, Vector2(x + 320, y), s[1], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, AMBER)
		y += 24

	draw_string(font, Vector2(12, vp.y - 12), "[ESC] Back", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, DIM_GREEN)


## ============================================================================
## HELPERS
## ============================================================================

func _draw_sub_header(vp: Vector2, font: Font, title: String) -> void:
	var title_size := font.get_string_size(title, HORIZONTAL_ALIGNMENT_CENTER, -1, 20)
	draw_string(font, Vector2((vp.x - title_size.x) * 0.5, 50), title, HORIZONTAL_ALIGNMENT_CENTER, -1, 20, GREEN)

	## Separator line
	draw_line(Vector2(40, 66), Vector2(vp.x - 40, 66), BORDER, 1.0)


func _input_sub(event: InputEvent) -> void:
	if event.keycode == KEY_ESCAPE:
		_current_screen = Screen.MAIN


func _load_sector_info() -> void:
	## Temporarily create a GridManager to read sector data
	_grid_temp = GridManagerScript.new()
	add_child(_grid_temp)
	_sector_list = _grid_temp.get_available_sectors()
	for sid in _sector_list:
		_sector_data[sid] = _grid_temp.get_sector_info(sid)
	_grid_temp.queue_free()
	_grid_temp = null


func _gui_input(event: InputEvent) -> void:
	if _current_screen != Screen.MAIN:
		return
	if event is InputEventMouseMotion:
		_hovered_item = _get_menu_item_at(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var item: int = _get_menu_item_at(event.position)
		if item >= 0 and item < MENU_ITEMS.size():
			_current_screen = MENU_ITEMS[item]["screen"]


func _get_menu_item_at(pos: Vector2) -> int:
	var vp := get_viewport_rect().size
	var menu_x: float = (vp.x - 280) * 0.5
	var menu_y: float = 160.0
	var item_h: float = 36.0

	for i in MENU_ITEMS.size():
		var rect := Rect2(menu_x, menu_y + i * item_h, 280, item_h - 4)
		if rect.has_point(pos):
			return i
	return -1
