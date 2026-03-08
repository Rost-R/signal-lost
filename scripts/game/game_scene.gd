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

var _grid: Node2D
var _pathfinder: Node
var _wave_spawner: Node
var _relay_core: Node2D
var _hud: CanvasLayer
var _reward_system: Node
var _reward_panel: CanvasLayer
var _game_over_panel: CanvasLayer

## Tower creation
var _tower_scenes: Dictionary = {}


## ============================================================================
## LIFECYCLE
## ============================================================================

func _ready() -> void:
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
	## Grid
	_grid = GridManagerScript.new()
	_grid.name = "Grid"
	add_child(_grid)

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

	## Relay Core (visual)
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

	## Game Over Panel (overlay, on top of everything)
	_game_over_panel = GameOverPanelScript.new()
	_game_over_panel.name = "GameOverPanel"
	add_child(_game_over_panel)

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
	_wave_spawner.wave_enemies_cleared.connect(_on_wave_cleared)
	_wave_spawner.enemy_spawned.connect(_on_enemy_spawned)
	GameManager.game_over.connect(_on_game_over)
	_reward_panel.reward_selected.connect(_on_reward_selected)
	_game_over_panel.restart_requested.connect(_on_restart_requested)
	_game_over_panel.main_menu_requested.connect(_on_main_menu_requested)


## ============================================================================
## GAME FLOW
## ============================================================================

func _start_game() -> void:
	_reward_system.reset()
	RunManager.start_new_run()
	GameManager.start_run()


func _on_start_wave() -> void:
	if GameManager.current_phase != GameManager.GamePhase.BUILD and \
	   GameManager.current_phase != GameManager.GamePhase.BETWEEN_WAVES:
		return

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

	## Detect flawless wave (no core damage taken this wave)
	var was_flawless: bool = GameManager.core_hp >= GameManager.core_hp_before_wave

	## Generate and show 3 reward choices
	var choices: Array = _reward_system.generate_choices(
		GameManager.current_wave, was_flawless
	)
	_reward_panel.show_choices(choices)


func _on_reward_selected(reward: Dictionary) -> void:
	_reward_system.apply_reward(reward)
	GameManager.finish_reward_choice()


func _on_game_over(victory: bool) -> void:
	## Short delay before showing game over panel
	get_tree().create_timer(1.5).timeout.connect(func():
		_game_over_panel.show_results(victory)
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

func _on_enemy_spawned(_enemy: Node2D) -> void:
	pass  # Future: connect signals for transmissions, etc.


## ============================================================================
## TOWER UPGRADE / SELL FROM HUD
## ============================================================================

var _selected_tower_pos: Vector2i = Vector2i(-1, -1)

func _on_tower_upgrade_requested() -> void:
	var tower: Node2D = _grid.get_tower_at(_selected_tower_pos)
	if tower and tower.has_method("upgrade"):
		tower.upgrade()
		_recalculate_synergies(_selected_tower_pos)


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
