## ============================================================================
## PULSE EMITTER
## ============================================================================
##
## Purpose: Single-target, high DPS tower. Fires focused energy beams.
## Synergy: +damage when target is debuffed by Scrambler Dish, 2x damage to frozen enemies.
##
## @author Signal Lost Team
## @version 0.1.0
class_name PulseEmitter
extends "res://scripts/towers/tower_base.gd"


## ============================================================================
## CONSTANTS
## ============================================================================

const UPGRADE_DATA := [
	{}, # Level 1 (base stats from exports)
	{ "damage": 40.0, "attack_speed": 1.4, "range": 4.0, "cost": 80 },
	{ "damage": 65.0, "attack_speed": 1.6, "range": 4.5, "cost": 110 },
]

## Branch upgrade paths (chosen at level 2)
const BRANCH_DATA := {
	"a": {
		"name": "Precision Pulse",
		"description": "+DMG, +Range. High single-target burst.",
		"level_2": { "damage": 45.0, "attack_speed": 1.3, "range": 4.5, "cost": 80 },
		"level_3": { "damage": 80.0, "attack_speed": 1.4, "range": 5.0, "cost": 110 },
	},
	"b": {
		"name": "Burst Pulse",
		"description": "+Speed, -DMG per hit. Rapid-fire DPS.",
		"level_2": { "damage": 28.0, "attack_speed": 2.2, "range": 3.5, "cost": 80 },
		"level_3": { "damage": 38.0, "attack_speed": 3.0, "range": 4.0, "cost": 110 },
	},
}

## Visual — beam flash duration
const BEAM_FLASH_DURATION := 0.1
var _beam_flash_timer: float = 0.0
var _last_target_pos: Vector2 = Vector2.ZERO


## ============================================================================
## LIFECYCLE
## ============================================================================

func _init() -> void:
	tower_id = "pulse_emitter"
	tower_name = "Pulse Emitter"
	base_damage = 25.0
	base_attack_speed = 1.2
	base_range = 3.5
	base_cost = 50
	power_cost = 1
	tower_color = Color(0, 0.78, 1)  # #00C8FF


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _beam_flash_timer > 0:
		_beam_flash_timer -= delta
		queue_redraw()


## ============================================================================
## ATTACK
## ============================================================================

func _attack(target: Node2D) -> void:
	var damage := effective_damage

	## Synergy: 2x damage to frozen enemies
	if target.has_method("is_frozen") and target.is_frozen():
		damage *= 2.0

	if target.has_method("take_damage"):
		target.take_damage(damage)

	## Visual beam
	_last_target_pos = target.global_position - global_position
	_beam_flash_timer = BEAM_FLASH_DURATION


## ============================================================================
## STATS
## ============================================================================

func _get_level_stats() -> Dictionary:
	if level <= 1:
		return { "damage": base_damage, "attack_speed": base_attack_speed, "range": base_range }
	## Use branch data if a branch was chosen
	if upgrade_branch != "":
		var key := "level_%d" % level
		var data: Dictionary = BRANCH_DATA[upgrade_branch].get(key, {})
		return {
			"damage": data.get("damage", base_damage),
			"attack_speed": data.get("attack_speed", base_attack_speed),
			"range": data.get("range", base_range),
		}
	## Fallback to linear upgrades
	var data: Dictionary = UPGRADE_DATA[level - 1]
	return {
		"damage": data.get("damage", base_damage),
		"attack_speed": data.get("attack_speed", base_attack_speed),
		"range": data.get("range", base_range),
	}


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

	## Draw beam flash when attacking
	if _beam_flash_timer > 0 and _last_target_pos != Vector2.ZERO:
		var alpha := _beam_flash_timer / BEAM_FLASH_DURATION
		draw_line(Vector2.ZERO, _last_target_pos, Color(0, 0.78, 1, alpha), 2.0)
