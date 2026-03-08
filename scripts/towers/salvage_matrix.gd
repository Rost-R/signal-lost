## ============================================================================
## SALVAGE MATRIX
## ============================================================================
##
## Purpose: Economy / utility / adaptive support tower. Generates bonus scrap
## from enemy kills in range and provides a small passive scrap income between
## waves. Weak in panic situations but enables greedy high-cost builds.
## Synergy: Boosts scrap generation from adjacent towers' kills (handled internally).
##
## @author Signal Lost Team
## @version 0.1.0
class_name SalvageMatrix
extends "res://scripts/towers/tower_base.gd"


## ============================================================================
## CONSTANTS
## ============================================================================

const UPGRADE_DATA := [
	{},
	{ "bonus_scrap": 4, "passive_income": 6, "range": 3.5, "cost": 130 },
	{ "bonus_scrap": 6, "passive_income": 10, "range": 4.0, "cost": 175 },
]

## Branch upgrade paths
const BRANCH_DATA := {
	"a": {
		"name": "Salvage Drone",
		"description": "+Scrap per kill, +Passive income. Max greed.",
		"level_2": { "bonus_scrap": 5, "passive_income": 8, "range": 3.5, "cost": 130 },
		"level_3": { "bonus_scrap": 8, "passive_income": 14, "range": 4.0, "cost": 175 },
	},
	"b": {
		"name": "Power Redistributor",
		"description": "+1 Power cap per level. Less scrap.",
		"level_2": { "bonus_scrap": 3, "passive_income": 4, "range": 3.5, "power_cap_bonus": 1, "cost": 130 },
		"level_3": { "bonus_scrap": 4, "passive_income": 6, "range": 4.0, "power_cap_bonus": 2, "cost": 175 },
	},
}

const PULSE_DURATION := 0.3

## ============================================================================
## STATE
## ============================================================================

var base_bonus_scrap: int = 2      # Extra scrap per kill in range
var base_passive_income: int = 3   # Scrap earned between waves
var _pulse_timer: float = 0.0
var _total_scrap_earned: int = 0
var _power_cap_bonus_applied: int = 0  ## Track how much power cap we've added


## ============================================================================
## LIFECYCLE
## ============================================================================

func _init() -> void:
	tower_id = "salvage_matrix"
	tower_name = "Salvage Matrix"
	base_damage = 0.0
	base_attack_speed = 0.0  # Not attack-based
	base_range = 3.0
	base_cost = 80
	power_cost = 1
	tower_color = Color(0.2, 0.9, 0.4)  # #33E566 — green


func _ready() -> void:
	super._ready()
	add_to_group("salvage_towers")
	## Connect to wave completion for passive income
	GameManager.wave_completed.connect(_on_wave_completed)


func _physics_process(delta: float) -> void:
	if _pulse_timer > 0:
		_pulse_timer -= delta
		queue_redraw()

	## Monitor enemies dying in range
	_check_kills_in_range()


## ============================================================================
## SALVAGE LOGIC
## ============================================================================

## Check for enemies that just died in range and award bonus scrap.
func _check_kills_in_range() -> void:
	if not GameManager.is_running:
		return
	if GameManager.current_phase != GameManager.GamePhase.WAVE and \
	   GameManager.current_phase != GameManager.GamePhase.BOSS:
		return

	var range_px := effective_range * GridManagerScript.CELL_SIZE
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		## Check if enemy is dying (HP <= 0) and in range
		if enemy.has_method("get_current_hp") and enemy.get_current_hp() <= 0:
			var dist := position.distance_to(enemy.position)
			if dist <= range_px:
				_award_bonus_scrap(enemy)


## Award bonus scrap for a kill. Marks enemy to prevent double-counting.
func _award_bonus_scrap(enemy: Node2D) -> void:
	## Prevent double-counting using a meta flag
	if enemy.has_meta("salvage_collected"):
		return
	enemy.set_meta("salvage_collected", true)

	var bonus := _get_effective_bonus_scrap()
	GameManager.add_scrap(bonus)
	_total_scrap_earned += bonus
	_pulse_timer = PULSE_DURATION
	queue_redraw()


## Called when a wave completes — award passive income.
func _on_wave_completed(_wave_number: int) -> void:
	var income := _get_effective_passive_income()
	GameManager.add_scrap(income)
	_total_scrap_earned += income


## Get effective bonus scrap for current level.
func _get_effective_bonus_scrap() -> int:
	if level <= 1:
		return base_bonus_scrap
	if upgrade_branch != "":
		var key := "level_%d" % level
		return BRANCH_DATA.get(upgrade_branch, {}).get(key, {}).get("bonus_scrap", base_bonus_scrap)
	return UPGRADE_DATA[level - 1].get("bonus_scrap", base_bonus_scrap)


## Get effective passive income for current level.
func _get_effective_passive_income() -> int:
	if level <= 1:
		return base_passive_income
	if upgrade_branch != "":
		var key := "level_%d" % level
		return BRANCH_DATA.get(upgrade_branch, {}).get(key, {}).get("passive_income", base_passive_income)
	return UPGRADE_DATA[level - 1].get("passive_income", base_passive_income)


## Apply or update power cap bonus (Power Redistributor branch).
func _update_power_cap_bonus() -> void:
	var target_bonus := 0
	if upgrade_branch == "b" and level >= 2:
		var key := "level_%d" % level
		target_bonus = BRANCH_DATA["b"].get(key, {}).get("power_cap_bonus", 0)
	var delta_bonus := target_bonus - _power_cap_bonus_applied
	if delta_bonus != 0:
		GameManager.power_cap += delta_bonus
		_power_cap_bonus_applied = target_bonus


## Remove power cap bonus when tower is sold/freed.
func _remove_power_cap_bonus() -> void:
	if _power_cap_bonus_applied > 0:
		GameManager.power_cap -= _power_cap_bonus_applied
		_power_cap_bonus_applied = 0


## ============================================================================
## STATS
## ============================================================================

func recalculate_stats() -> void:
	super.recalculate_stats()
	_update_power_cap_bonus()


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


func _exit_tree() -> void:
	_remove_power_cap_bonus()


## ============================================================================
## DRAWING
## ============================================================================

func _draw() -> void:
	super._draw()

	## Draw salvage field radius
	var range_px := effective_range * GridManagerScript.CELL_SIZE
	var pulse: float = 0.05 + abs(sin(Time.get_ticks_msec() * 0.002)) * 0.05
	draw_arc(Vector2.ZERO, range_px, 0, TAU, 64, Color(0.2, 0.9, 0.4, pulse), 1.0)

	## Scrap collection pulse effect
	if _pulse_timer > 0:
		var alpha := _pulse_timer / PULSE_DURATION
		var pulse_radius := range_px * (1.0 - alpha) * 0.5
		draw_arc(Vector2.ZERO, pulse_radius, 0, TAU, 32, Color(0.2, 0.9, 0.4, alpha * 0.4), 2.0)
