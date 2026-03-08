## ============================================================================
## PRISM BEAM
## ============================================================================
##
## Purpose: Linear high-risk high-reward damage tower. Fires a piercing beam
## that hits ALL enemies in a line. Huge positional payoff but requires correct
## map geometry to maximize value. Costs 2 power.
## Synergy: +30% damage when adjacent to Cryo Node (applied in game_scene.gd).
##
## @author Signal Lost Team
## @version 0.1.0
class_name PrismBeam
extends "res://scripts/towers/tower_base.gd"


## ============================================================================
## CONSTANTS
## ============================================================================

const UPGRADE_DATA := [
	{},
	{ "damage": 35.0, "attack_speed": 0.7, "range": 5.0, "beam_width": 14.0, "cost": 145 },
	{ "damage": 55.0, "attack_speed": 0.8, "range": 6.0, "beam_width": 18.0, "cost": 200 },
]

## Branch upgrade paths
const BRANCH_DATA := {
	"a": {
		"name": "Focused Beam",
		"description": "+DMG, narrower beam. Devastating single-line.",
		"level_2": { "damage": 45.0, "attack_speed": 0.7, "range": 5.0, "beam_width": 10.0, "cost": 145 },
		"level_3": { "damage": 75.0, "attack_speed": 0.8, "range": 6.0, "beam_width": 8.0, "cost": 200 },
	},
	"b": {
		"name": "Refracted Beam",
		"description": "Fires 2-3 beams. Less DMG each, wider coverage.",
		"level_2": { "damage": 22.0, "attack_speed": 0.6, "range": 4.5, "beam_width": 14.0, "beam_count": 2, "cost": 145 },
		"level_3": { "damage": 30.0, "attack_speed": 0.7, "range": 5.0, "beam_width": 16.0, "beam_count": 3, "cost": 200 },
	},
}

const BASE_BEAM_WIDTH := 10.0
const BEAM_FLASH_DURATION := 0.2

## ============================================================================
## STATE
## ============================================================================

var _beam_flash_timer: float = 0.0
var _beam_direction: Vector2 = Vector2.ZERO
var _beam_directions: Array[Vector2] = []  ## Refracted Beam: multiple directions
var _beam_length: float = 0.0


## ============================================================================
## LIFECYCLE
## ============================================================================

func _init() -> void:
	tower_id = "prism_beam"
	tower_name = "Prism Beam"
	base_damage = 22.0
	base_attack_speed = 0.6
	base_range = 4.5
	base_cost = 90
	power_cost = 2
	tower_color = Color(1, 0.84, 0)  # #FFD700 — gold


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _beam_flash_timer > 0:
		_beam_flash_timer -= delta
		queue_redraw()


## ============================================================================
## ATTACK
## ============================================================================

## Override attack to fire a piercing beam through ALL enemies in a line.
func _attack(target: Node2D) -> void:
	var damage := effective_damage
	var range_px := effective_range * GridManagerScript.CELL_SIZE
	var beam_w := _get_effective_beam_width()
	var beam_count := _get_effective_beam_count()

	## Direction from tower to primary target
	var main_dir := (target.global_position - global_position).normalized()

	## Build list of beam directions
	_beam_directions.clear()
	if beam_count <= 1:
		_beam_directions.append(main_dir)
	else:
		## Spread beams evenly around main direction
		var spread := deg_to_rad(15.0)  ## 15 degrees between beams
		for i in beam_count:
			var offset_angle := (i - (beam_count - 1) * 0.5) * spread
			var rotated := main_dir.rotated(offset_angle)
			_beam_directions.append(rotated)

	## Fire each beam
	var enemies := get_tree().get_nodes_in_group("enemies")
	for dir in _beam_directions:
		for enemy in enemies:
			if not is_instance_valid(enemy) or not enemy.visible:
				continue
			var to_enemy := enemy.global_position - global_position
			var proj := to_enemy.dot(dir)
			if proj < 0 or proj > range_px:
				continue
			var perp_dist := abs(to_enemy.cross(dir))
			if perp_dist <= beam_w * 0.5:
				if enemy.has_method("take_damage"):
					enemy.take_damage(damage)

	## Visual
	_beam_direction = main_dir
	_beam_length = range_px
	_beam_flash_timer = BEAM_FLASH_DURATION


## Get effective beam width for current level.
func _get_effective_beam_width() -> float:
	if level <= 1:
		return BASE_BEAM_WIDTH
	if upgrade_branch != "":
		var key := "level_%d" % level
		return BRANCH_DATA.get(upgrade_branch, {}).get(key, {}).get("beam_width", BASE_BEAM_WIDTH)
	return UPGRADE_DATA[level - 1].get("beam_width", BASE_BEAM_WIDTH)


## Get beam count (Refracted Beam branch fires multiple beams).
func _get_effective_beam_count() -> int:
	if upgrade_branch == "b" and level >= 2:
		var key := "level_%d" % level
		return BRANCH_DATA["b"].get(key, {}).get("beam_count", 1)
	return 1


## ============================================================================
## STATS
## ============================================================================

func _get_level_stats() -> Dictionary:
	if level <= 1:
		return { "damage": base_damage, "attack_speed": base_attack_speed, "range": base_range }
	if upgrade_branch != "":
		var key := "level_%d" % level
		var data: Dictionary = BRANCH_DATA[upgrade_branch].get(key, {})
		return {
			"damage": data.get("damage", base_damage),
			"attack_speed": data.get("attack_speed", base_attack_speed),
			"range": data.get("range", base_range),
		}
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

	## Draw piercing beam(s)
	if _beam_flash_timer > 0 and _beam_directions.size() > 0:
		var alpha := _beam_flash_timer / BEAM_FLASH_DURATION
		var beam_w := _get_effective_beam_width()
		for dir in _beam_directions:
			var beam_end := dir * _beam_length
			draw_line(Vector2.ZERO, beam_end, Color(1, 0.84, 0, alpha), beam_w * 0.5)
			draw_line(Vector2.ZERO, beam_end, Color(1, 1, 0.9, alpha * 0.8), 2.0)
