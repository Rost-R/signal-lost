## ============================================================================
## GAME SCENE
## ============================================================================
##
## Purpose: Main game scene. Orchestrates all systems: grid, towers,
## enemies, waves, pathfinding, HUD, rewards, and game over flow.
##
## @author Signal Lost Team
## @version 0.3.0
extends Node2D

## Preload all scripts to avoid class_name resolution issues
const GridManagerScript = preload("res://scripts/systems/grid_manager.gd")
const PathfinderScript = preload("res://scripts/systems/pathfinder.gd")
const WaveSpawnerScript = preload("res://scripts/systems/wave_spawner.gd")
const RelayCoreScript = preload("res://scripts/systems/relay_core.gd")
const RewardSystemScript = preload("res://scripts/systems/reward_system.gd")
const GameHUDScript = preload("res://scripts/ui/game_hud.gd")
const RewardPanelScript = preload("res://scripts/ui/reward_panel.gd")
const GameOverPanelScript = preload("res://scripts/ui/game_over_panel.gd")
const PulseEmitterScript = preload("res://scripts/towers/pulse_emitter.gd")
const ArcRelayScript = preload("res://scripts/towers/arc_relay.gd")
const CryoNodeScript = preload("res://scripts/towers/cryo_node.gd")
const ScramblerDishScript = preload("res://scripts/towers/scrambler_dish.gd")
const PrismBeamScript = preload("res://scripts/towers/prism_beam.gd")
const SalvageMatrixScript = preload("res://scripts/towers/salvage_matrix.gd")
const TowerBaseScript = preload("res://scripts/towers/tower_base.gd")
const TransmissionManagerScript = preload("res://scripts/systems/transmission_manager.gd")
const TransmissionPanelScript = preload("res://scripts/ui/transmission_panel.gd")
const CrtOverlayScript = preload("res://scripts/systems/crt_overlay.gd")
const ModifierManagerScript = preload("res://scripts/systems/modifier_manager.gd")
const ModifierSelectionPanelScript = preload("res://scripts/ui/modifier_selection_panel.gd")


## ============================================================================
## TOWER POWER COSTS — centralized lookup
## ============================================================================

const TOWER_POWER_COSTS := {
	"pulse_emitter": 1,
	"arc_relay": 1,
	"cryo_node": 1,
	"scrambler_dish": 1,
	"prism_beam": 2,
	"salvage_matrix": 1,
}


## ============================================================================
## STATE
## ============================================================================

## Sector to load (set before scene enters tree, e.g. from hub)
var sector_id: String = "relay_spine"

var _grid: Node2D
var _pathfinder: Node
var _wave_spawner: Node
var _relay_core: Node2D
var _hud: CanvasLayer
var _reward_system: Node
var _reward_panel: CanvasLayer
var _game_over_panel: CanvasLayer
var _transmission_manager: Node
var _transmission_panel: CanvasLayer
var _crt_overlay: CanvasLayer
var _modifier_manager: Node
var _modifier_panel: CanvasLayer

## Tower creation
var _tower_scenes: Dictionary = {}


## ============================================================================
## LIFECYCLE
## ============================================================================

func _ready() -> void:
	## Read sector from RunManager (set by hub terminal)
	if RunManager.sector_id != "":
		sector_id = RunManager.sector_id
	_setup_systems()
	_connect_signals()
	_start_game()


func _exit_tree() -> void:
	## Free all placed towers to prevent leaked RIDs on scene reload
	for pos in _grid.get_all_tower_positions():
		var tower: Node2D = _grid.get_tower_at(pos)
		if tower and is_instance_valid(tower):
			tower.queue_free()


func _unhandled_input(event: InputEvent) -> void:
	## Block game input during reward choice and game over
	if GameManager.current_phase == GameManager.GamePhase.REWARD_CHOICE:
		return
	if GameManager.current_phase == GameManager.GamePhase.GAME_OVER:
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_click(get_global_mouse_position())
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_handle_right_click(get_global_mouse_position())


## ============================================================================
## SETUP
## ============================================================================

func _setup_systems() -> void:
	## Grid — load sector before pathfinder setup
	_grid = GridManagerScript.new()
	_grid.name = "Grid"
	add_child(_grid)
	_grid.load_sector(sector_id)

	## Pathfinder
	_pathfinder = PathfinderScript.new()
	_pathfinder.name = "Pathfinder"
	add_child(_pathfinder)
	_pathfinder.setup(_grid)

	## Wave Spawner
	_wave_spawner = WaveSpawnerScript.new()
	_wave_spawner.name = "WaveSpawner"
	add_child(_wave_spawner)
	_wave_spawner.setup(_pathfinder, _grid)

	## Relay Core (visual) — position based on sector's core location
	_relay_core = RelayCoreScript.new()
	_relay_core.name = "RelayCore"
	_relay_core.position = _grid.grid_to_world(_grid.core_position)
	add_child(_relay_core)

	## Reward System
	_reward_system = RewardSystemScript.new()
	_reward_system.name = "RewardSystem"
	add_child(_reward_system)

	## HUD
	_hud = GameHUDScript.new()
	_hud.name = "HUD"
	add_child(_hud)

	## Reward Panel (overlay, on top of HUD)
	_reward_panel = RewardPanelScript.new()
	_reward_panel.name = "RewardPanel"
	add_child(_reward_panel)

	## Transmission Manager
	_transmission_manager = TransmissionManagerScript.new()
	_transmission_manager.name = "TransmissionManager"
	add_child(_transmission_manager)

	## Transmission Panel (overlay)
	_transmission_panel = TransmissionPanelScript.new()
	_transmission_panel.name = "TransmissionPanel"
	add_child(_transmission_panel)

	## Game Over Panel (overlay, on top of everything)
	_game_over_panel = GameOverPanelScript.new()
	_game_over_panel.name = "GameOverPanel"
	add_child(_game_over_panel)

	## Modifier Manager
	_modifier_manager = ModifierManagerScript.new()
	_modifier_manager.name = "ModifierManager"
	add_child(_modifier_manager)

	## Modifier Selection Panel (overlay, shown before first wave)
	_modifier_panel = ModifierSelectionPanelScript.new()
	_modifier_panel.name = "ModifierPanel"
	add_child(_modifier_panel)

	## CRT Overlay (post-processing, renders on top of ALL layers)
	_crt_overlay = CrtOverlayScript.new()
	_crt_overlay.name = "CRTOverlay"
	add_child(_crt_overlay)

	## Load tower scenes
	_tower_scenes["pulse_emitter"] = _create_tower_scene(PulseEmitterScript)
	_tower_scenes["arc_relay"] = _create_tower_scene(ArcRelayScript)
	_tower_scenes["cryo_node"] = _create_tower_scene(CryoNodeScript)
	_tower_scenes["scrambler_dish"] = _create_tower_scene(ScramblerDishScript)
	_tower_scenes["prism_beam"] = _create_tower_scene(PrismBeamScript)
	_tower_scenes["salvage_matrix"] = _create_tower_scene(SalvageMatrixScript)


func _connect_signals() -> void:
	_hud.start_wave_pressed.connect(_on_start_wave)
	_hud.tower_upgrade_requested.connect(_on_tower_upgrade_requested)
	_hud.tower_sell_requested.connect(_on_tower_sell_requested)
	_hud.branch_selected.connect(_on_branch_selected)
	_wave_spawner.wave_enemies_cleared.connect(_on_wave_cleared)
	_wave_spawner.enemy_spawned.connect(_on_enemy_spawned)
	GameManager.game_over.connect(_on_game_over)
	_reward_panel.reward_selected.connect(_on_reward_selected)
	_game_over_panel.restart_requested.connect(_on_restart_requested)
	_game_over_panel.main_menu_requested.connect(_on_main_menu_requested)
	_transmission_panel.transmission_selected.connect(_on_transmission_selected)
	_transmission_panel.transmission_skipped.connect(_on_transmission_skipped)
	_modifier_panel.modifier_chosen.connect(_on_modifier_chosen)
	_modifier_panel.modifier_skipped.connect(_on_modifier_skipped)


## ============================================================================
## GAME FLOW
## ============================================================================

func _start_game() -> void:
	_reward_system.reset()
	_transmission_manager.reset()
	_modifier_manager.reset()
	RunManager.start_new_run()
	GameManager.start_run()
	## Show modifier selection before first wave
	var choices: Array[Dictionary] = _modifier_manager.generate_choices()
	_modifier_panel.show_choices(choices)


func _on_start_wave() -> void:
	if GameManager.current_phase != GameManager.GamePhase.BUILD and \
	   GameManager.current_phase != GameManager.GamePhase.BETWEEN_WAVES:
		return

	## Clear wave preview when wave starts
	_hud.set_wave_preview([])
	GameManager.start_wave()
	_wave_spawner.start_wave(GameManager.current_wave)


func _on_wave_cleared() -> void:
	## Award wave reward scrap defined in waves.json
	var wave_reward: int = _wave_spawner.get_wave_reward_scrap(GameManager.current_wave)
	if wave_reward > 0:
		GameManager.add_scrap(wave_reward)
		RunManager.scrap_earned += wave_reward

	GameManager.complete_wave()

	## If game is over (victory on wave 10), skip reward choice
	if GameManager.current_phase == GameManager.GamePhase.GAME_OVER:
		return

	## Set preview for next wave
	var next_wave := GameManager.current_wave + 1
	if next_wave <= GameManager.MAX_WAVES:
		_hud.set_wave_preview(_wave_spawner.get_wave_preview(next_wave))
	else:
		_hud.set_wave_preview([])

	## Check for story window (transmission choice before reward)
	if _transmission_manager.is_story_window(GameManager.current_wave):
		var tx_choices: Array = _transmission_manager.generate_choices(GameManager.current_wave)
		if not tx_choices.is_empty():
			_transmission_panel.show_choices(tx_choices)
			return  ## Wait for transmission selection before showing rewards

	_show_reward_choices()


func _show_reward_choices() -> void:
	## Detect flawless wave (no core damage taken this wave)
	var was_flawless: bool = GameManager.core_hp >= GameManager.core_hp_before_wave

	## Generate and show 3 reward choices
	var choices: Array = _reward_system.generate_choices(
		GameManager.current_wave, was_flawless
	)
	_reward_panel.show_choices(choices)


func _on_transmission_selected(transmission: Dictionary) -> void:
	var tx_id: String = transmission.get("tx_id", "")
	if tx_id != "":
		_transmission_manager.select_transmission(tx_id)
	_show_reward_choices()


func _on_transmission_skipped() -> void:
	_show_reward_choices()


func _on_reward_selected(reward: Dictionary) -> void:
	_reward_system.apply_reward(reward)
	GameManager.finish_reward_choice()


func _on_modifier_chosen(modifier_id: String) -> void:
	_modifier_manager.select_modifier(modifier_id)
	## Show wave 1 preview after modifier selection
	_hud.set_wave_preview(_wave_spawner.get_wave_preview(1))


func _on_modifier_skipped() -> void:
	## No modifier — proceed directly to build phase
	_hud.set_wave_preview(_wave_spawner.get_wave_preview(1))


func _on_game_over(victory: bool) -> void:
	## Determine ending based on truth axes
	var ending: Dictionary = _transmission_manager.determine_ending(victory)

	## Record run results in MetaManager for persistent progression
	var currency := 5 + RunManager.waves_survived * 2  ## Base fragments earned
	if victory:
		currency += 10
	MetaManager.record_run_end(RunManager.waves_survived, victory, currency)

	## Unlock any transmissions seen this run
	for tx_id in RunManager.transmissions_seen:
		MetaManager.unlock_transmission(tx_id)

	## Short delay before showing game over panel with ending
	get_tree().create_timer(1.5).timeout.connect(func():
		_game_over_panel.show_results(victory, ending)
	)


func _on_restart_requested() -> void:
	GameManager.reset()
	get_tree().reload_current_scene()


func _on_main_menu_requested() -> void:
	GameManager.reset()
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")


## ============================================================================
## ENEMY SPAWN HANDLING
## ============================================================================

func _on_enemy_spawned(enemy: Node2D) -> void:
	## Apply run modifier effects to enemy (HP, speed, reward multipliers)
	_modifier_manager.apply_run_effects_to_enemy(enemy)

	## Roll for elite modifier and apply if selected
	var elite_type: int = _modifier_manager.roll_elite_type(GameManager.current_wave)
	if elite_type != 0:
		_modifier_manager.apply_elite_to_enemy(enemy, elite_type)


## ============================================================================
## TOWER UPGRADE / SELL FROM HUD
## ============================================================================

var _selected_tower_pos: Vector2i = Vector2i(-1, -1)

func _on_tower_upgrade_requested() -> void:
	var tower: Node2D = _grid.get_tower_at(_selected_tower_pos)
	if not tower or not tower.has_method("upgrade"):
		return
	## Connect branch choice signal if tower has branches (one-shot)
	if tower.has_method("_has_branches") and tower._has_branches() and tower.level == 1:
		if not tower.branch_choice_needed.is_connected(_on_branch_choice_needed):
			tower.branch_choice_needed.connect(_on_branch_choice_needed, CONNECT_ONE_SHOT)
	tower.upgrade()
	_recalculate_synergies(_selected_tower_pos)


func _on_branch_choice_needed(_tower: Node2D, branches: Array) -> void:
	_hud.show_branch_choice(branches)


func _on_branch_selected(branch_id: String) -> void:
	var tower: Node2D = _grid.get_tower_at(_selected_tower_pos)
	if tower and tower.has_method("upgrade_with_branch"):
		tower.upgrade_with_branch(branch_id)
		_recalculate_synergies(_selected_tower_pos)
		_hud.show_tower_info(tower)  ## Refresh info panel


func _on_tower_sell_requested() -> void:
	var tower: Node2D = _grid.get_tower_at(_selected_tower_pos)
	if tower:
		_sell_tower(_selected_tower_pos, tower)
		_selected_tower_pos = Vector2i(-1, -1)


## ============================================================================
## TOWER PLACEMENT
## ============================================================================

func _handle_click(world_pos: Vector2) -> void:
	var grid_pos: Vector2i = _grid.world_to_grid(world_pos)

	## If we have a tower selected and click on a valid slot, place it
	var tower_id: String = _hud.get_selected_tower_id()
	if tower_id != "" and _grid.can_place_tower(grid_pos):
		_place_tower(grid_pos, tower_id)
		return

	## If clicking on an existing tower, select it for info
	var existing: Node2D = _grid.get_tower_at(grid_pos)
	if existing and existing.has_method("set_range_visible"):
		## Deselect previous tower
		if _selected_tower_pos != Vector2i(-1, -1):
			var prev: Node2D = _grid.get_tower_at(_selected_tower_pos)
			if prev and prev.has_method("set_range_visible"):
				prev.set_range_visible(false)
		_selected_tower_pos = grid_pos
		existing.set_range_visible(true)
		_hud.show_tower_info(existing)
	elif _selected_tower_pos != Vector2i(-1, -1):
		## Clicked empty space — deselect
		var prev: Node2D = _grid.get_tower_at(_selected_tower_pos)
		if prev and prev.has_method("set_range_visible"):
			prev.set_range_visible(false)
		_selected_tower_pos = Vector2i(-1, -1)
		_hud.hide_tower_info()


func _handle_right_click(world_pos: Vector2) -> void:
	var grid_pos: Vector2i = _grid.world_to_grid(world_pos)
	var tower: Node2D = _grid.get_tower_at(grid_pos)
	if tower and tower.has_method("get_sell_value"):
		_sell_tower(grid_pos, tower)


func _place_tower(grid_pos: Vector2i, tower_id: String) -> void:
	var base_cost: int = _get_tower_cost(tower_id)
	var cost: int = _reward_system.get_discounted_cost(base_cost)
	## Apply tower cost modifier
	var cost_mult: float = _modifier_manager.get_effect("tower_cost_multiply", 1.0)
	if cost_mult != 1.0:
		cost = int(cost * cost_mult)
	var p_cost: int = TOWER_POWER_COSTS.get(tower_id, 1)

	## Check scrap
	if not GameManager.spend_scrap(cost):
		return

	## Check power
	if not GameManager.can_use_power(p_cost):
		GameManager.add_scrap(cost)  # Refund scrap
		return

	var scene: PackedScene = _tower_scenes.get(tower_id)
	if not scene:
		GameManager.add_scrap(cost)
		return

	var tower: Node2D = scene.instantiate()
	tower.grid_position = grid_pos
	add_child(tower)

	if not _grid.place_tower(grid_pos, tower):
		tower.queue_free()
		GameManager.add_scrap(cost)
		return

	GameManager.use_power(p_cost)

	## Power node bonus: placing on a power node grants +1 power cap
	if _grid.get_node_type(grid_pos) == GridManagerScript.NodeType.POWER:
		GameManager.add_power_cap(1)

	_recalculate_synergies(grid_pos)


func _sell_tower(grid_pos: Vector2i, tower: Node2D) -> void:
	var refund: int = tower.get_sell_value()
	## Apply improved sell refund if reward was chosen
	if _reward_system.run_sell_refund > 0.70:
		var base_invested: int = tower.get_total_invested() if tower.has_method("get_total_invested") else int(refund / 0.70)
		refund = _reward_system.get_sell_value(base_invested)
	var p_cost: int = tower.power_cost if "power_cost" in tower else 1
	GameManager.add_scrap(refund)
	GameManager.release_power(p_cost)

	## Reverse power node bonus when selling from a power node
	if _grid.get_node_type(grid_pos) == GridManagerScript.NodeType.POWER:
		GameManager.remove_power_cap(1)

	var adj_positions: Array[Vector2i] = _grid.get_adjacent_towers(grid_pos)
	_grid.remove_tower(grid_pos)
	tower.queue_free()

	## Recalculate synergies for former neighbors
	for adj_pos in adj_positions:
		_apply_synergies_for(adj_pos)

	_hud.hide_tower_info()


## ============================================================================
## SYNERGY CALCULATION
## ============================================================================

func _recalculate_synergies(grid_pos: Vector2i) -> void:
	## Recalculate synergies for this tower AND all its neighbors
	_apply_synergies_for(grid_pos)
	for adj_pos in _grid.get_adjacent_towers(grid_pos):
		_apply_synergies_for(adj_pos)


func _apply_synergies_for(grid_pos: Vector2i) -> void:
	var tower: Node2D = _grid.get_tower_at(grid_pos)
	if not tower or not tower.has_method("apply_synergy"):
		return

	## Start with run-wide bonuses from reward choices
	var damage_mult: float = 1.0 + _reward_system.run_damage_bonus
	var speed_mult: float = 1.0 + _reward_system.run_speed_bonus
	var range_mult: float = 1.0 + _reward_system.run_range_bonus

	## Apply run modifier bonuses
	damage_mult *= _modifier_manager.get_effect("tower_damage_multiply", 1.0)
	speed_mult *= _modifier_manager.get_effect("tower_attack_speed_multiply", 1.0)
	range_mult *= _modifier_manager.get_effect("tower_range_multiply", 1.0)

	## Relay node bonus: towers on relay nodes get +15% range
	if _grid.get_node_type(grid_pos) == GridManagerScript.NodeType.RELAY:
		range_mult += 0.15

	var adjacent_towers: Array[Node2D] = _grid.get_adjacent_tower_nodes(grid_pos)
	var tower_id: String = tower.get_tower_id() if tower.has_method("get_tower_id") else ""

	for adj in adjacent_towers:
		if not adj.has_method("get_tower_id"):
			continue
		var adj_id: String = adj.get_tower_id()

		## Scrambler Dish + Pulse synergy: Pulse gets +20% damage near Scrambler
		if adj_id == "scrambler_dish" and tower_id == "pulse_emitter":
			damage_mult += 0.20

	## Arc Relay chain bonus from adjacent Arc Relays
	if tower.has_method("set_chain_bonus"):
		var arc_count: int = _grid.count_adjacent_of_type(grid_pos, "arc_relay")
		tower.set_chain_bonus(arc_count)

	## Cryo + Prism synergy: Prism Beam gets +30% damage near Cryo
	if tower_id == "prism_beam":
		var cryo_count: int = _grid.count_adjacent_of_type(grid_pos, "cryo_node")
		if cryo_count > 0:
			damage_mult += 0.30

	tower.apply_synergy(damage_mult, speed_mult, range_mult)


## ============================================================================
## HELPERS
## ============================================================================

func _get_tower_cost(tower_id: String) -> int:
	match tower_id:
		"pulse_emitter": return 50
		"arc_relay": return 70
		"cryo_node": return 60
		"scrambler_dish": return 75
		"prism_beam": return 90
		"salvage_matrix": return 80
		_: return 50


func _create_tower_scene(script: GDScript) -> PackedScene:
	var node := Node2D.new()
	node.set_script(script)
	var scene := PackedScene.new()
	scene.pack(node)
	return scene
