## ============================================================================
## CRYO NODE
## ============================================================================
##
## Purpose: Area slow/freeze tower. Slows all enemies in range.
## Enemies that stay in range long enough get frozen solid.
## Synergy: Frozen enemies take 2x from Pulse Emitter.
##
## @author Signal Lost Team
## @version 0.1.0
class_name CryoNode
extends "res://scripts/towers/tower_base.gd"

## GridManagerScript inherited from TowerBase via preload()


## ============================================================================
## CONSTANTS
## ============================================================================

const UPGRADE_DATA := [
	{},
	{ "slow_percent": 55.0, "range": 3.0, "freeze_duration": 2.0, "cost": 95 },
	{ "slow_percent": 70.0, "range": 3.5, "freeze_duration": 2.5, "cost": 130 },
]

## Branch upgrade paths
const BRANCH_DATA := {
	"a": {
		"name": "Deep Freeze",
		"description": "+Slow%, +Freeze duration. Long lockdown.",
		"level_2": { "slow_percent": 60.0, "range": 2.8, "freeze_duration": 2.5, "freeze_threshold": 2.5, "cost": 95 },
		"level_3": { "slow_percent": 80.0, "range": 3.0, "freeze_duration": 3.5, "freeze_threshold": 2.0, "cost": 130 },
	},
	"b": {
		"name": "Fracture Chill",
		"description": "Frozen enemies take +50% DMG from all sources.",
		"level_2": { "slow_percent": 50.0, "range": 3.0, "freeze_duration": 1.5, "shatter_bonus": 1.3, "cost": 95 },
		"level_3": { "slow_percent": 60.0, "range": 3.5, "freeze_duration": 2.0, "shatter_bonus": 1.5, "cost": 130 },
	},
}

const FREEZE_THRESHOLD := 3.0  # Seconds of continuous slow before freeze


## ============================================================================
## STATE
## ============================================================================

var base_slow_percent: float = 40.0
var base_freeze_duration: float = 1.5
var shatter_bonus: float = 0.0  ## Fracture Chill branch: extra damage multiplier on frozen

## Track how long each enemy has been in range (for freeze threshold).
var _enemy_exposure: Dictionary = {}  # enemy_id -> seconds


## ============================================================================
## LIFECYCLE
## ============================================================================

func _init() -> void:
	tower_id = "cryo_node"
	tower_name = "Cryo Node"
	base_damage = 0.0
	base_attack_speed = 0.0  # Not attack-based
	base_range = 2.5
	base_cost = 60
	power_cost = 1
	tower_color = Color(0.53, 0.87, 1)  # #88DDFF


func _physics_process(delta: float) -> void:
	if not GameManager.is_running:
		return
	if GameManager.current_phase != GameManager.GamePhase.WAVE and \
	   GameManager.current_phase != GameManager.GamePhase.BOSS:
		return

	_apply_slow_field(delta)
	queue_redraw()


## ============================================================================
## SLOW FIELD LOGIC
## ============================================================================

func _apply_slow_field(delta: float) -> void:
	var range_px := effective_range * GridManagerScript.CELL_SIZE
	var slow := _get_effective_slow()
	var freeze_dur := _get_effective_freeze_duration()
	var enemies := get_tree().get_nodes_in_group("enemies")
	var in_range_ids: Array[int] = []

	for enemy in enemies:
		if not is_instance_valid(enemy) or not enemy.visible:
			continue
		var dist := position.distance_to(enemy.position)
		if dist > range_px:
			continue

		var eid := enemy.get_instance_id()
		in_range_ids.append(eid)

		## Apply slow
		if enemy.has_method("apply_slow"):
			enemy.apply_slow(slow)

		## Track exposure for freeze
		_enemy_exposure[eid] = _enemy_exposure.get(eid, 0.0) + delta

		## Freeze if threshold reached
		if _enemy_exposure[eid] >= _get_effective_freeze_threshold():
			if enemy.has_method("apply_freeze"):
				var shatter := get_shatter_bonus()
				enemy.apply_freeze(freeze_dur, shatter)
			_enemy_exposure[eid] = 0.0  # Reset after freeze

	## Clean up enemies that left range
	for eid in _enemy_exposure.keys():
		if eid not in in_range_ids:
			_enemy_exposure.erase(eid)


## Get effective slow percent for current level.
func _get_effective_slow() -> float:
	if level <= 1:
		return base_slow_percent
	if upgrade_branch != "":
		var key := "level_%d" % level
		return BRANCH_DATA.get(upgrade_branch, {}).get(key, {}).get("slow_percent", base_slow_percent)
	return UPGRADE_DATA[level - 1].get("slow_percent", base_slow_percent)


## Get effective freeze duration for current level.
func _get_effective_freeze_duration() -> float:
	if level <= 1:
		return base_freeze_duration
	if upgrade_branch != "":
		var key := "level_%d" % level
		return BRANCH_DATA.get(upgrade_branch, {}).get(key, {}).get("freeze_duration", base_freeze_duration)
	return UPGRADE_DATA[level - 1].get("freeze_duration", base_freeze_duration)


## Get freeze threshold (Deep Freeze branch reduces it).
func _get_effective_freeze_threshold() -> float:
	if upgrade_branch != "" and level >= 2:
		var key := "level_%d" % level
		return BRANCH_DATA.get(upgrade_branch, {}).get(key, {}).get("freeze_threshold", FREEZE_THRESHOLD)
	return FREEZE_THRESHOLD


## Get shatter bonus multiplier (Fracture Chill branch).
func get_shatter_bonus() -> float:
	if upgrade_branch == "b" and level >= 2:
		var key := "level_%d" % level
		return BRANCH_DATA["b"].get(key, {}).get("shatter_bonus", 0.0)
	return 0.0


## ============================================================================
## STATS
## ============================================================================

func _get_level_stats() -> Dictionary:
	var r := base_range
	if level > 1:
		if upgrade_branch != "":
			var key := "level_%d" % level
			r = BRANCH_DATA.get(upgrade_branch, {}).get(key, {}).get("range", base_range)
		elif level <= UPGRADE_DATA.size():
			r = UPGRADE_DATA[level - 1].get("range", base_range)
	return { "damage": 0.0, "attack_speed": 0.0, "range": r }


func _get_upgrade_cost(target_level: int) -> int:
	if upgrade_branch != "":
		return _get_branch_upgrade_cost(upgrade_branch, target_level)
	if target_level <= 1 or target_level > UPGRADE_DATA.size():
		return base_cost
	return UPGRADE_DATA[target_level - 1].get("cost", base_cost)


func _has_branches() -> bool:
	return true


func _get_branch_info() -> Array:
	return [
		{ "id": "a", "name": BRANCH_DATA["a"]["name"], "description": BRANCH_DATA["a"]["description"], "cost": BRANCH_DATA["a"]["level_2"]["cost"] },
		{ "id": "b", "name": BRANCH_DATA["b"]["name"], "description": BRANCH_DATA["b"]["description"], "cost": BRANCH_DATA["b"]["level_2"]["cost"] },
	]


func _get_branch_upgrade_cost(branch_id: String, target_level: int) -> int:
	var key := "level_%d" % target_level
	return BRANCH_DATA.get(branch_id, {}).get(key, {}).get("cost", base_cost)


## ============================================================================
## DRAWING
## ============================================================================

func _draw() -> void:
	super._draw()

	## Draw freeze field radius
	var range_px := effective_range * GridManagerScript.CELL_SIZE
	## Pulsing effect
	var pulse: float = 0.05 + abs(sin(Time.get_ticks_msec() * 0.003)) * 0.05
	draw_arc(Vector2.ZERO, range_px, 0, TAU, 64, Color(0.53, 0.87, 1, pulse), 1.0)

	## Inner ring
	draw_arc(Vector2.ZERO, range_px * 0.5, 0, TAU, 32, Color(0.53, 0.87, 1, pulse * 0.5), 1.0)
