## ============================================================================
## WAVE SPAWNER
## ============================================================================
##
## Purpose: Spawns enemy waves based on wave data. Manages spawn timing,
## group delays, and wave completion detection.
##
## @author Signal Lost Team
## @version 0.1.0
class_name WaveSpawner
extends Node

## Preload scripts to avoid class_name resolution issues
const GlitchSwarmScript = preload("res://scripts/enemies/glitch_swarm.gd")
const CorruptedCarrierScript = preload("res://scripts/enemies/corrupted_carrier.gd")
const MirrorFragmentScript = preload("res://scripts/enemies/mirror_fragment.gd")
const NullShieldScript = preload("res://scripts/enemies/null_shield.gd")
const PhaseLeechScript = preload("res://scripts/enemies/phase_leech.gd")
const ParasitePacketScript = preload("res://scripts/enemies/parasite_packet.gd")
const TheChoirScript = preload("res://scripts/enemies/the_choir.gd")
const BlackRelayScript = preload("res://scripts/enemies/black_relay.gd")


## ============================================================================
## SIGNALS
## ============================================================================

signal wave_enemies_cleared()
signal enemy_spawned(enemy: Node2D)


## ============================================================================
## STATE
## ============================================================================

var _pathfinder: Node
var _grid_manager: Node2D
var _wave_data: Dictionary = {}
var _spawn_queue: Array[Dictionary] = []  # { enemy_id, delay_timer, count, interval, spawned }
var _active_enemies: Array[Node2D] = []
var _is_spawning: bool = false
var _wave_timer: float = 0.0

## Enemy scenes — loaded once
var _enemy_scenes: Dictionary = {}


## ============================================================================
## LIFECYCLE
## ============================================================================

func _ready() -> void:
	_load_wave_data()
	_load_enemy_scenes()


func _exit_tree() -> void:
	## Free all active enemies to prevent leaked RIDs on scene reload
	for enemy in _active_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	_active_enemies.clear()


func _physics_process(delta: float) -> void:
	if not _is_spawning:
		return

	_wave_timer += delta
	_process_spawn_queue(delta)
	_cleanup_dead_enemies()

	## Check wave completion
	if _spawn_queue.is_empty() and _active_enemies.is_empty():
		_is_spawning = false
		wave_enemies_cleared.emit()


## ============================================================================
## PUBLIC API
## ============================================================================

func setup(pathfinder: Node, grid_manager: Node2D) -> void:
	_pathfinder = pathfinder
	_grid_manager = grid_manager


## Start spawning a wave by number (1-10).
func start_wave(wave_number: int) -> void:
	var wave_key := "wave_%d" % wave_number
	var wave: Dictionary = _wave_data.get("wave_templates", {}).get(wave_key, {})
	if wave.is_empty():
		push_warning("WaveSpawner: No data for %s" % wave_key)
		return

	_spawn_queue.clear()
	_wave_timer = 0.0
	_is_spawning = true

	## Build spawn queue from wave groups
	var groups: Array = wave.get("groups", [])
	for group in groups:
		_spawn_queue.append({
			"enemy_id": group.get("enemy", "glitch_swarm"),
			"delay": group.get("delay", 0.0),
			"count": group.get("count", 1),
			"interval": _get_spawn_interval(group.get("enemy", "glitch_swarm")),
			"spawned": 0,
			"spawn_timer": 0.0,
			"started": false,
		})


## Get count of active enemies on the field.
func get_active_enemy_count() -> int:
	return _active_enemies.size()


## Get wave preview info (enemy types + counts) for a given wave.
## Returns array of { "enemy": "enemy_id", "count": N, "name": "Enemy Name" }
func get_wave_preview(wave_number: int) -> Array:
	var wave_key := "wave_%d" % wave_number
	var wave: Dictionary = _wave_data.get("wave_templates", {}).get(wave_key, {})
	if wave.is_empty():
		return []
	var preview: Array = []
	var groups: Array = wave.get("groups", [])
	for group in groups:
		var enemy_id: String = group.get("enemy", "glitch_swarm")
		var count: int = group.get("count", 1)
		## Merge counts for same enemy type
		var found := false
		for p in preview:
			if p["enemy"] == enemy_id:
				p["count"] += count
				found = true
				break
		if not found:
			preview.append({
				"enemy": enemy_id,
				"count": count,
				"name": enemy_id.replace("_", " ").capitalize(),
			})
	return preview


## Get the reward scrap defined in waves.json for a given wave.
func get_wave_reward_scrap(wave_number: int) -> int:
	var wave_key := "wave_%d" % wave_number
	var wave: Dictionary = _wave_data.get("wave_templates", {}).get(wave_key, {})
	return int(wave.get("reward_scrap", 0))


## ============================================================================
## PRIVATE
## ============================================================================

func _process_spawn_queue(delta: float) -> void:
	var completed: Array[int] = []

	for i in _spawn_queue.size():
		var group: Dictionary = _spawn_queue[i]

		## Wait for delay
		if not group["started"]:
			if _wave_timer >= group["delay"]:
				group["started"] = true
				group["spawn_timer"] = group["interval"]  # Spawn first immediately
			else:
				continue

		## Spawn enemies at interval
		group["spawn_timer"] += delta
		while group["spawn_timer"] >= group["interval"] and group["spawned"] < group["count"]:
			group["spawn_timer"] -= group["interval"]
			_spawn_enemy(group["enemy_id"])
			group["spawned"] += 1

		if group["spawned"] >= group["count"]:
			completed.append(i)

	## Remove completed groups (reverse order to preserve indices)
	completed.reverse()
	for idx in completed:
		_spawn_queue.remove_at(idx)


func _spawn_enemy(enemy_id: String) -> void:
	var scene: PackedScene = _enemy_scenes.get(enemy_id)
	if not scene:
		push_warning("WaveSpawner: No scene for enemy '%s'" % enemy_id)
		return

	var enemy: Node2D = scene.instantiate()
	add_child(enemy)

	## Get path from first spawn point to core
	var spawn: Vector2i = _grid_manager.spawn_points[0] if _grid_manager.spawn_points.size() > 0 else Vector2i(0, 4)
	var path: PackedVector2Array = _pathfinder.get_path_to_core(spawn)

	if path.is_empty():
		push_warning("WaveSpawner: No valid path for enemy")
		enemy.queue_free()
		return

	## Apply wave scaling
	var wave_mult := _get_wave_scaling()
	enemy.setup(path, wave_mult)

	## Connect death/core signals
	enemy.enemy_died.connect(_on_enemy_died)
	enemy.enemy_reached_core.connect(_on_enemy_reached_core)

	_active_enemies.append(enemy)
	enemy_spawned.emit(enemy)


func _on_enemy_died(enemy: Node2D) -> void:
	_remove_enemy(enemy)


func _on_enemy_reached_core(enemy: Node2D) -> void:
	_remove_enemy(enemy)


func _remove_enemy(enemy: Node2D) -> void:
	_active_enemies.erase(enemy)
	enemy.visible = false
	enemy.set_physics_process(false)
	## Defer free to avoid issues during iteration
	enemy.call_deferred("queue_free")


func _cleanup_dead_enemies() -> void:
	_active_enemies = _active_enemies.filter(
		func(e: Node2D) -> bool: return is_instance_valid(e) and e.visible
	)


func _get_wave_scaling() -> float:
	var base: float = _wave_data.get("scaling", {}).get("base_multiplier", 1.0)
	var per_wave: float = _wave_data.get("scaling", {}).get("per_wave_multiplier", 1.12)
	return base * pow(per_wave, GameManager.current_wave - 1)


func _get_spawn_interval(enemy_id: String) -> float:
	## Default intervals per enemy type
	match enemy_id:
		"glitch_swarm": return 0.3
		"corrupted_carrier": return 0.8
		"mirror_fragment": return 1.0
		"null_shield": return 1.2
		"phase_leech": return 1.5
		"parasite_packet": return 1.0
		"the_choir": return 0.0
		"black_relay": return 0.0
		_: return 0.5


## ============================================================================
## DATA LOADING
## ============================================================================

func _load_wave_data() -> void:
	var file := FileAccess.open("res://data/waves.json", FileAccess.READ)
	if file:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK:
			_wave_data = json.data
		file.close()


func _load_enemy_scenes() -> void:
	## For MVP, we create scenes programmatically since we use _draw()
	## In production these would be .tscn files
	_enemy_scenes["glitch_swarm"] = _create_enemy_scene(GlitchSwarmScript)
	_enemy_scenes["corrupted_carrier"] = _create_enemy_scene(CorruptedCarrierScript)
	_enemy_scenes["mirror_fragment"] = _create_enemy_scene(MirrorFragmentScript)
	_enemy_scenes["null_shield"] = _create_enemy_scene(NullShieldScript)
	_enemy_scenes["phase_leech"] = _create_enemy_scene(PhaseLeechScript)
	_enemy_scenes["parasite_packet"] = _create_enemy_scene(ParasitePacketScript)
	_enemy_scenes["the_choir"] = _create_enemy_scene(TheChoirScript)
	_enemy_scenes["black_relay"] = _create_enemy_scene(BlackRelayScript)


func _create_enemy_scene(script: GDScript) -> PackedScene:
	var node := Node2D.new()
	node.set_script(script)
	var scene := PackedScene.new()
	scene.pack(node)
	return scene
