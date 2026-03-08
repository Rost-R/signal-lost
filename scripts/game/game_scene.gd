## ============================================================================
## GAME SCENE
## ============================================================================
##
## Purpose: Main game scene. Orchestrates all systems: grid, towers,
## enemies, waves, pathfinding, and HUD.
##
## @author Signal Lost Team
## @version 0.1.0
extends Node2D

## Preload all scripts to avoid class_name resolution issues
const GridManagerScript = preload("res://scripts/systems/grid_manager.gd")
const PathfinderScript = preload("res://scripts/systems/pathfinder.gd")
const WaveSpawnerScript = preload("res://scripts/systems/wave_spawner.gd")
const RelayCoreScript = preload("res://scripts/systems/relay_core.gd")
const GameHUDScript = preload("res://scripts/ui/game_hud.gd")
const PulseEmitterScript = preload("res://scripts/towers/pulse_emitter.gd")
const ArcRelayScript = preload("res://scripts/towers/arc_relay.gd")
const CryoNodeScript = preload("res://scripts/towers/cryo_node.gd")
const TowerBaseScript = preload("res://scripts/towers/tower_base.gd")


## ============================================================================
## STATE
## ============================================================================

var _grid: Node2D
var _pathfinder: Node
var _wave_spawner: Node
var _relay_core: Node2D
var _hud: CanvasLayer

## Tower creation
var _tower_scenes: Dictionary = {}


## ============================================================================
## LIFECYCLE
## ============================================================================

func _ready() -> void:
	_setup_systems()
	_connect_signals()
	_start_game()


func _unhandled_input(event: InputEvent) -> void:
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

	## HUD
	_hud = GameHUDScript.new()
	_hud.name = "HUD"
	add_child(_hud)

	## Load tower scenes
	_tower_scenes["pulse_emitter"] = _create_tower_scene(PulseEmitterScript)
	_tower_scenes["arc_relay"] = _create_tower_scene(ArcRelayScript)
	_tower_scenes["cryo_node"] = _create_tower_scene(CryoNodeScript)


func _connect_signals() -> void:
	_hud.start_wave_pressed.connect(_on_start_wave)
	_wave_spawner.wave_enemies_cleared.connect(_on_wave_cleared)
	GameManager.game_over.connect(_on_game_over)


## ============================================================================
## GAME FLOW
## ============================================================================

func _start_game() -> void:
	GameManager.start_run()


func _on_start_wave() -> void:
	if GameManager.current_phase != GameManager.GamePhase.BUILD and \
	   GameManager.current_phase != GameManager.GamePhase.BETWEEN_WAVES:
		return

	GameManager.start_wave()
	_wave_spawner.start_wave(GameManager.current_wave)


func _on_wave_cleared() -> void:
	GameManager.complete_wave()


func _on_game_over(victory: bool) -> void:
	if victory:
		print("=== VICTORY! All waves cleared! ===")
	else:
		print("=== GAME OVER — Core destroyed ===")
	print("Waves survived: %d" % GameManager.current_wave)
	print("Resources earned: %d" % RunManager.resources_earned)
	print("Enemies killed: %d" % RunManager.enemies_killed)

	get_tree().create_timer(3.0).timeout.connect(func():
		GameManager.reset()
		get_tree().reload_current_scene()
	)


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
		existing.set_range_visible(true)


func _handle_right_click(world_pos: Vector2) -> void:
	var grid_pos: Vector2i = _grid.world_to_grid(world_pos)
	var tower: Node2D = _grid.get_tower_at(grid_pos)
	if tower and tower.has_method("get_sell_value"):
		_sell_tower(grid_pos, tower)


func _place_tower(grid_pos: Vector2i, tower_id: String) -> void:
	var cost: int = _get_tower_cost(tower_id)
	if not GameManager.spend_resources(cost):
		return

	var scene: PackedScene = _tower_scenes.get(tower_id)
	if not scene:
		return

	var tower: Node2D = scene.instantiate()
	tower.grid_position = grid_pos
	add_child(tower)

	if not _grid.place_tower(grid_pos, tower):
		tower.queue_free()
		GameManager.add_resources(cost)
		return

	_recalculate_synergies(grid_pos)


func _sell_tower(grid_pos: Vector2i, tower: Node2D) -> void:
	var refund: int = tower.get_sell_value()
	GameManager.add_resources(refund)
	_grid.remove_tower(grid_pos)
	tower.queue_free()

	for adj_pos in _grid.get_adjacent_towers(grid_pos):
		_recalculate_synergies(adj_pos)


## ============================================================================
## SYNERGY CALCULATION
## ============================================================================

func _recalculate_synergies(grid_pos: Vector2i) -> void:
	var tower: Node2D = _grid.get_tower_at(grid_pos)
	if not tower or not tower.has_method("apply_synergy"):
		return

	var damage_mult: float = 1.0
	var speed_mult: float = 1.0
	var range_mult: float = 1.0

	var adjacent_towers: Array[Node2D] = _grid.get_adjacent_tower_nodes(grid_pos)

	for adj in adjacent_towers:
		if not adj.has_method("get_tower_id"):
			continue

		## Amplifier boosts adjacent non-amplifiers
		if adj.get_tower_id() == "amplifier" and tower.get_tower_id() != "amplifier":
			var amp_bonus: float = 0.2 * adj.level
			var amp_adj_count: int = _grid.count_adjacent_non_amplifier(adj.grid_position)
			if amp_adj_count >= 3:
				amp_bonus *= 2.0
			damage_mult += amp_bonus
			speed_mult += amp_bonus * 0.5
			range_mult += amp_bonus * 0.5

	## Arc Relay chain bonus from adjacent Arc Relays
	if tower.has_method("set_chain_bonus"):
		var arc_count: int = _grid.count_adjacent_of_type(grid_pos, "arc_relay")
		tower.set_chain_bonus(arc_count)

	tower.apply_synergy(damage_mult, speed_mult, range_mult)

	## Also recalculate neighbors
	for adj_pos in _grid.get_adjacent_towers(grid_pos):
		var adj_tower: Node2D = _grid.get_tower_at(adj_pos)
		if adj_tower and adj_tower.has_method("recalculate_stats"):
			adj_tower.recalculate_stats()


## ============================================================================
## HELPERS
## ============================================================================

func _get_tower_cost(tower_id: String) -> int:
	match tower_id:
		"pulse_emitter": return 100
		"arc_relay": return 150
		"cryo_node": return 120
		_: return 100


func _create_tower_scene(script: GDScript) -> PackedScene:
	var node := Node2D.new()
	node.set_script(script)
	var scene := PackedScene.new()
	scene.pack(node)
	return scene
