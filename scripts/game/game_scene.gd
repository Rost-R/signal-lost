## ============================================================================
## GAME SCENE
## ============================================================================
##
## Purpose: Main game scene. Orchestrates all systems: grid, towers,
## enemies, waves, pathfinding, and HUD.
##
## @author Signal Lost Team
## @version 0.1.0
class_name GameScene
extends Node2D


## ============================================================================
## STATE
## ============================================================================

var _grid: GridManager
var _pathfinder: Pathfinder
var _wave_spawner: WaveSpawner
var _relay_core: RelayCore
var _hud: GameHUD

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
	_grid = GridManager.new()
	_grid.name = "Grid"
	add_child(_grid)

	## Pathfinder
	_pathfinder = Pathfinder.new()
	_pathfinder.name = "Pathfinder"
	add_child(_pathfinder)
	_pathfinder.setup(_grid)

	## Wave Spawner
	_wave_spawner = WaveSpawner.new()
	_wave_spawner.name = "WaveSpawner"
	add_child(_wave_spawner)
	_wave_spawner.setup(_pathfinder, _grid)

	## Relay Core (visual)
	_relay_core = RelayCore.new()
	_relay_core.name = "RelayCore"
	_relay_core.position = _grid.grid_to_world(_grid.core_position)
	add_child(_relay_core)

	## HUD
	_hud = GameHUD.new()
	_hud.name = "HUD"
	add_child(_hud)

	## Load tower scenes
	_tower_scenes["pulse_emitter"] = _create_tower_scene(PulseEmitter)
	_tower_scenes["arc_relay"] = _create_tower_scene(ArcRelay)
	_tower_scenes["cryo_node"] = _create_tower_scene(CryoNode)


func _connect_signals() -> void:
	## HUD signals
	_hud.start_wave_pressed.connect(_on_start_wave)

	## Wave signals
	_wave_spawner.wave_enemies_cleared.connect(_on_wave_cleared)

	## Game Manager signals
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

	## TODO: Show end-of-run screen
	## For MVP, just restart after a delay
	get_tree().create_timer(3.0).timeout.connect(func():
		GameManager.reset()
		get_tree().reload_current_scene()
	)


## ============================================================================
## TOWER PLACEMENT
## ============================================================================

func _handle_click(world_pos: Vector2) -> void:
	var grid_pos := _grid.world_to_grid(world_pos)

	## If we have a tower selected and click on a valid slot, place it
	var tower_id := _hud.get_selected_tower_id()
	if tower_id != "" and _grid.can_place_tower(grid_pos):
		_place_tower(grid_pos, tower_id)
		return

	## If clicking on an existing tower, select it for info
	var existing := _grid.get_tower_at(grid_pos)
	if existing:
		existing.set_range_visible(true)
		## TODO: Show tower info panel


func _handle_right_click(world_pos: Vector2) -> void:
	var grid_pos := _grid.world_to_grid(world_pos)
	var tower := _grid.get_tower_at(grid_pos)
	if tower and tower is TowerBase:
		_sell_tower(grid_pos, tower)


func _place_tower(grid_pos: Vector2i, tower_id: String) -> void:
	var cost := _get_tower_cost(tower_id)
	if not GameManager.spend_resources(cost):
		return  # Can't afford

	var scene: PackedScene = _tower_scenes.get(tower_id)
	if not scene:
		return

	var tower: TowerBase = scene.instantiate()
	tower.grid_position = grid_pos
	add_child(tower)

	if not _grid.place_tower(grid_pos, tower):
		tower.queue_free()
		GameManager.add_resources(cost)  # Refund
		return

	## Recalculate synergies for this tower and neighbors
	_recalculate_synergies(grid_pos)


func _sell_tower(grid_pos: Vector2i, tower: TowerBase) -> void:
	var refund := tower.get_sell_value()
	GameManager.add_resources(refund)
	_grid.remove_tower(grid_pos)
	tower.queue_free()

	## Recalculate synergies for neighbors
	for adj_pos in _grid.get_adjacent_towers(grid_pos):
		_recalculate_synergies(adj_pos)


## ============================================================================
## SYNERGY CALCULATION
## ============================================================================

func _recalculate_synergies(grid_pos: Vector2i) -> void:
	var tower := _grid.get_tower_at(grid_pos)
	if not tower or not tower is TowerBase:
		return

	var damage_mult := 1.0
	var speed_mult := 1.0
	var range_mult := 1.0

	## Check adjacent towers for synergy effects
	var adjacent_towers := _grid.get_adjacent_tower_nodes(grid_pos)

	for adj in adjacent_towers:
		if not adj is TowerBase:
			continue

		## Amplifier boosts adjacent non-amplifiers
		if adj.tower_id == "amplifier" and tower.tower_id != "amplifier":
			damage_mult += adj.effective_damage  # Using buff percentages stored as stats
			## Simplified: Amplifier gives flat +20% per level
			var amp_bonus := 0.2 * adj.level
			## Check if amplifier is surrounded (doubled effect)
			var amp_adj_count := _grid.count_adjacent_non_amplifier(adj.grid_position)
			if amp_adj_count >= 3:
				amp_bonus *= 2.0
			damage_mult += amp_bonus
			speed_mult += amp_bonus * 0.5
			range_mult += amp_bonus * 0.5

	## Arc Relay chain bonus from adjacent Arc Relays
	if tower is ArcRelay:
		var arc_count := _grid.count_adjacent_of_type(grid_pos, "arc_relay")
		tower.set_chain_bonus(arc_count)

	## Apply synergy multipliers (capped at 3x in tower_base)
	tower.apply_synergy(damage_mult, speed_mult, range_mult)

	## Also recalculate neighbors (their synergies may depend on this tower)
	for adj_pos in _grid.get_adjacent_towers(grid_pos):
		var adj_tower := _grid.get_tower_at(adj_pos)
		if adj_tower and adj_tower is TowerBase:
			## Avoid infinite recursion — only recalc if it hasn't been done
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
