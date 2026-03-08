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
const DataSiphonScript = preload("res://scripts/towers/data_siphon.gd")
const AmplifierScript = preload("res://scripts/towers/amplifier.gd")
const ShieldGeneratorScript = preload("res://scripts/towers/shield_generator.gd")
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


func _exit_tree() -> void:
	## Free all placed towers to prevent leaked RIDs on scene reload
	for pos in _grid.get_all_tower_positions():
		var tower: Node2D = _grid.get_tower_at(pos)
		if tower and is_instance_valid(tower):
			tower.queue_free()


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
	_tower_scenes["data_siphon"] = _create_tower_scene(DataSiphonScript)
	_tower_scenes["amplifier"] = _create_tower_scene(AmplifierScript)
	_tower_scenes["shield_generator"] = _create_tower_scene(ShieldGeneratorScript)


func _connect_signals() -> void:
	_hud.start_wave_pressed.connect(_on_start_wave)
	_hud.tower_upgrade_requested.connect(_on_tower_upgrade_requested)
	_hud.tower_sell_requested.connect(_on_tower_sell_requested)
	_wave_spawner.wave_enemies_cleared.connect(_on_wave_cleared)
	_wave_spawner.enemy_spawned.connect(_on_enemy_spawned)
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
## SHIELD INTEGRATION
## ============================================================================

## Intercept enemy reaching core — shields absorb damage first.
func _on_enemy_spawned(enemy: Node2D) -> void:
	if enemy.has_signal("enemy_reached_core"):
		enemy.enemy_reached_core.connect(_on_enemy_reached_core_with_shield)


func _on_enemy_reached_core_with_shield(enemy: Node2D) -> void:
	var damage: int = enemy.damage_to_core if "damage_to_core" in enemy else 1

	## Try to absorb damage through shield generators
	var shield_towers := _get_shield_generators()
	for shield in shield_towers:
		if damage <= 0:
			break
		damage = shield.absorb_damage(damage)

	## Apply remaining damage to core (subtract the already-applied damage and re-add difference)
	## The enemy_base already called damage_core, so we compensate by healing the absorbed amount
	var absorbed: int = (enemy.damage_to_core if "damage_to_core" in enemy else 1) - damage
	if absorbed > 0:
		GameManager.core_hp += absorbed  # Heal back what shields absorbed


func _get_shield_generators() -> Array[Node2D]:
	var result: Array[Node2D] = []
	for pos in _grid.get_all_tower_positions():
		var tower: Node2D = _grid.get_tower_at(pos)
		if tower and tower.has_method("absorb_damage"):
			result.append(tower)
	return result


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

	var damage_mult: float = 1.0
	var speed_mult: float = 1.0
	var range_mult: float = 1.0

	var adjacent_towers: Array[Node2D] = _grid.get_adjacent_tower_nodes(grid_pos)
	var tower_id: String = tower.get_tower_id() if tower.has_method("get_tower_id") else ""

	for adj in adjacent_towers:
		if not adj.has_method("get_tower_id"):
			continue
		var adj_id: String = adj.get_tower_id()

		## Amplifier boosts adjacent non-amplifiers
		if adj_id == "amplifier" and tower_id != "amplifier":
			var non_amp_count: int = _grid.count_adjacent_non_amplifier(adj.grid_position)
			if adj.has_method("get_buff_values"):
				var buffs: Dictionary = adj.get_buff_values(non_amp_count)
				damage_mult += buffs.get("damage", 0.0)
				speed_mult += buffs.get("speed", 0.0)
				range_mult += buffs.get("range", 0.0)

	## Arc Relay chain bonus from adjacent Arc Relays
	if tower.has_method("set_chain_bonus"):
		var arc_count: int = _grid.count_adjacent_of_type(grid_pos, "arc_relay")
		tower.set_chain_bonus(arc_count)

	## Shield Generator cryo adjacency synergy
	if tower.has_method("set_cryo_adjacent"):
		var has_cryo: bool = _grid.count_adjacent_of_type(grid_pos, "cryo_node") > 0
		tower.set_cryo_adjacent(has_cryo)

	tower.apply_synergy(damage_mult, speed_mult, range_mult)


## ============================================================================
## HELPERS
## ============================================================================

func _get_tower_cost(tower_id: String) -> int:
	match tower_id:
		"pulse_emitter": return 100
		"arc_relay": return 150
		"cryo_node": return 120
		"data_siphon": return 200
		"amplifier": return 180
		"shield_generator": return 250
		_: return 100


func _create_tower_scene(script: GDScript) -> PackedScene:
	var node := Node2D.new()
	node.set_script(script)
	var scene := PackedScene.new()
	scene.pack(node)
	return scene
