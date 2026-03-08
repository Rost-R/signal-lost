## ============================================================================
## DATA SIPHON
## ============================================================================
##
## Purpose: Economy tower. Generates bonus resources from enemy kills in range
## and provides passive income each wave. Does not attack directly.
## Synergy: +10% yield per decoded transmission this run.
##
## @author Signal Lost Team
## @version 0.1.0
class_name DataSiphon
extends "res://scripts/towers/tower_base.gd"

## GridManagerScript inherited from TowerBase via preload()


## ============================================================================
## CONSTANTS
## ============================================================================

const UPGRADE_DATA := [
	{},
	{ "resource_per_kill": 8, "range": 3.5, "passive_income": 25, "cost": 120 },
	{ "resource_per_kill": 12, "range": 4.0, "passive_income": 40, "cost": 240 },
]


## ============================================================================
## STATE
## ============================================================================

var base_resource_per_kill: int = 5
var base_passive_income: int = 15
var _tracked_enemies: Dictionary = {}  # instance_id -> bool (already rewarded)


## ============================================================================
## LIFECYCLE
## ============================================================================

func _init() -> void:
	tower_id = "data_siphon"
	tower_name = "Data Siphon"
	base_damage = 0.0
	base_attack_speed = 0.0  # Not attack-based
	base_range = 3.0
	base_cost = 200
	tower_color = Color(0, 1, 0.53)  # #00FF88


func _physics_process(delta: float) -> void:
	if not GameManager.is_running:
		return
	if GameManager.current_phase != GameManager.GamePhase.WAVE and \
	   GameManager.current_phase != GameManager.GamePhase.BOSS:
		return

	_monitor_kills_in_range()
	queue_redraw()


func _ready() -> void:
	super._ready()
	GameManager.wave_completed.connect(_on_wave_completed)


## ============================================================================
## RESOURCE GENERATION
## ============================================================================

## Monitor enemies dying within range to grant bonus resources.
func _monitor_kills_in_range() -> void:
	var range_px := effective_range * GridManagerScript.CELL_SIZE
	var enemies := get_tree().get_nodes_in_group("enemies")

	## Track enemies in range
	var current_ids: Array[int] = []
	for enemy in enemies:
		if not is_instance_valid(enemy) or not enemy.visible:
			continue
		var dist := position.distance_to(enemy.position)
		if dist <= range_px:
			var eid := enemy.get_instance_id()
			current_ids.append(eid)
			if not _tracked_enemies.has(eid):
				_tracked_enemies[eid] = false
				## Connect death signal for bonus
				if enemy.has_signal("enemy_died") and not enemy.enemy_died.is_connected(_on_tracked_enemy_died):
					enemy.enemy_died.connect(_on_tracked_enemy_died)

	## Clean up enemies that left range or died
	for eid in _tracked_enemies.keys():
		if eid not in current_ids:
			_tracked_enemies.erase(eid)


func _on_tracked_enemy_died(enemy: Node2D) -> void:
	var eid := enemy.get_instance_id()
	if _tracked_enemies.has(eid) and not _tracked_enemies[eid]:
		_tracked_enemies[eid] = true
		var bonus := _get_effective_resource_per_kill()
		GameManager.add_resources(bonus)
		RunManager.resources_earned += bonus


## Grant passive income at the end of each wave.
func _on_wave_completed(_wave_number: int) -> void:
	var income := _get_effective_passive_income()
	GameManager.add_resources(income)
	RunManager.resources_earned += income
	_tracked_enemies.clear()


## ============================================================================
## STATS
## ============================================================================

func _get_effective_resource_per_kill() -> int:
	if level <= 1:
		return base_resource_per_kill
	return UPGRADE_DATA[level - 1].get("resource_per_kill", base_resource_per_kill)


func _get_effective_passive_income() -> int:
	if level <= 1:
		return base_passive_income
	return UPGRADE_DATA[level - 1].get("passive_income", base_passive_income)


func _get_level_stats() -> Dictionary:
	var r := base_range
	if level > 1 and level <= UPGRADE_DATA.size():
		r = UPGRADE_DATA[level - 1].get("range", base_range)
	return {
		"damage": 0.0,
		"attack_speed": 0.0,
		"range": r
	}


func _get_upgrade_cost(target_level: int) -> int:
	if target_level <= 1 or target_level > UPGRADE_DATA.size():
		return base_cost
	return UPGRADE_DATA[target_level - 1].get("cost", base_cost)


## ============================================================================
## DRAWING
## ============================================================================

func _draw() -> void:
	super._draw()

	## Draw siphon field radius
	var range_px := effective_range * GridManagerScript.CELL_SIZE
	var pulse: float = 0.05 + abs(sin(Time.get_ticks_msec() * 0.002)) * 0.08
	draw_arc(Vector2.ZERO, range_px, 0, TAU, 64, Color(0, 1, 0.53, pulse), 1.0)

	## Data stream lines (rotating)
	var time_offset: float = Time.get_ticks_msec() * 0.001
	for i in 3:
		var angle := time_offset + deg_to_rad(120 * i)
		var inner := Vector2(cos(angle), sin(angle)) * range_px * 0.3
		var outer := Vector2(cos(angle), sin(angle)) * range_px * 0.7
		draw_line(inner, outer, Color(0, 1, 0.53, pulse * 2), 1.0)
