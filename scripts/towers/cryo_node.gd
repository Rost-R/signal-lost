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
extends TowerBase


## ============================================================================
## CONSTANTS
## ============================================================================

const UPGRADE_DATA := [
	{},
	{ "slow_percent": 55.0, "range": 3.0, "freeze_duration": 2.0, "cost": 80 },
	{ "slow_percent": 70.0, "range": 3.5, "freeze_duration": 2.5, "cost": 160 },
]

const FREEZE_THRESHOLD := 3.0  # Seconds of continuous slow before freeze


## ============================================================================
## STATE
## ============================================================================

var base_slow_percent: float = 40.0
var base_freeze_duration: float = 1.5

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
	base_cost = 120
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
	var range_px := effective_range * GridManager.CELL_SIZE
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
		if _enemy_exposure[eid] >= FREEZE_THRESHOLD:
			if enemy.has_method("apply_freeze"):
				enemy.apply_freeze(freeze_dur)
			_enemy_exposure[eid] = 0.0  # Reset after freeze

	## Clean up enemies that left range
	for eid in _enemy_exposure.keys():
		if eid not in in_range_ids:
			_enemy_exposure.erase(eid)


## Get effective slow percent for current level.
func _get_effective_slow() -> float:
	if level <= 1:
		return base_slow_percent
	return UPGRADE_DATA[level - 1].get("slow_percent", base_slow_percent)


## Get effective freeze duration for current level.
func _get_effective_freeze_duration() -> float:
	if level <= 1:
		return base_freeze_duration
	return UPGRADE_DATA[level - 1].get("freeze_duration", base_freeze_duration)


## ============================================================================
## STATS
## ============================================================================

func _get_level_stats() -> Dictionary:
	## Cryo Node doesn't use damage/attack_speed, but we still track range.
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

	## Draw freeze field radius
	var range_px := effective_range * GridManager.CELL_SIZE
	## Pulsing effect
	var pulse := 0.05 + abs(sin(Time.get_ticks_msec() * 0.003)) * 0.05
	draw_arc(Vector2.ZERO, range_px, 0, TAU, 64, Color(0.53, 0.87, 1, pulse), 1.0)

	## Inner ring
	draw_arc(Vector2.ZERO, range_px * 0.5, 0, TAU, 32, Color(0.53, 0.87, 1, pulse * 0.5), 1.0)
