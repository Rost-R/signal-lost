## ============================================================================
## ARC RELAY
## ============================================================================
##
## Purpose: Chain lightning tower. Hits primary target then chains to nearby
## enemies. Excellent crowd control against swarms.
## Synergy: +1 chain per adjacent Arc Relay (max +3 bonus).
##
## @author Signal Lost Team
## @version 0.1.0
class_name ArcRelay
extends "res://scripts/towers/tower_base.gd"


## ============================================================================
## CONSTANTS
## ============================================================================

const UPGRADE_DATA := [
	{},
	{ "damage": 22.0, "attack_speed": 0.9, "range": 3.0, "chain_count": 4, "cost": 110 },
	{ "damage": 30.0, "attack_speed": 1.0, "range": 3.0, "chain_count": 5, "cost": 155 },
]

## Branch upgrade paths
const BRANCH_DATA := {
	"a": {
		"name": "Long Arc",
		"description": "+Range, +DMG. Fewer chains but hits harder.",
		"level_2": { "damage": 25.0, "attack_speed": 0.9, "range": 4.0, "chain_count": 3, "cost": 110 },
		"level_3": { "damage": 38.0, "attack_speed": 1.0, "range": 5.0, "chain_count": 4, "cost": 155 },
	},
	"b": {
		"name": "Feedback Arc",
		"description": "+Chains, less falloff. Swarm shredder.",
		"level_2": { "damage": 18.0, "attack_speed": 0.9, "range": 3.0, "chain_count": 5, "chain_falloff": 0.85, "cost": 110 },
		"level_3": { "damage": 25.0, "attack_speed": 1.0, "range": 3.0, "chain_count": 7, "chain_falloff": 0.9, "cost": 155 },
	},
}

const MAX_CHAIN_DEPTH := 7  ## Increased to allow Feedback Arc level 3
const CHAIN_RANGE_PX := 128.0  # 2 cells
const CHAIN_DAMAGE_FALLOFF := 0.8
const CHAIN_FLASH_DURATION := 0.15

## ============================================================================
## STATE
## ============================================================================

var base_chain_count: int = 3
var _chain_bonus: int = 0  # From adjacent Arc Relay synergy
var _chain_points: Array[Vector2] = []
var _chain_flash_timer: float = 0.0


## ============================================================================
## LIFECYCLE
## ============================================================================

func _init() -> void:
	tower_id = "arc_relay"
	tower_name = "Arc Relay"
	base_damage = 15.0
	base_attack_speed = 0.8
	base_range = 3.0
	base_cost = 70
	power_cost = 1
	tower_color = Color(0.27, 0.53, 1)  # #4488FF


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _chain_flash_timer > 0:
		_chain_flash_timer -= delta
		queue_redraw()


## ============================================================================
## ATTACK
## ============================================================================

func _attack(target: Node2D) -> void:
	var chain_count := _get_effective_chain_count()
	var hit_enemies: Array[Node2D] = []
	_chain_points.clear()

	## Hit primary target
	var damage := effective_damage
	if target.has_method("take_damage"):
		target.take_damage(damage)
	hit_enemies.append(target)
	_chain_points.append(target.global_position - global_position)

	## Chain to nearby enemies
	var falloff := _get_effective_chain_falloff()
	var current_pos: Vector2 = target.global_position
	for i in chain_count:
		var next := _find_chain_target(current_pos, hit_enemies)
		if not next:
			break
		damage *= falloff
		if next.has_method("take_damage"):
			next.take_damage(damage)
		hit_enemies.append(next)
		_chain_points.append(next.global_position - global_position)
		current_pos = next.global_position

	_chain_flash_timer = CHAIN_FLASH_DURATION


## Find the next chain target closest to current position, not already hit.
func _find_chain_target(from_pos: Vector2, exclude: Array[Node2D]) -> Node2D:
	var best: Node2D = null
	var best_dist: float = CHAIN_RANGE_PX
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not is_instance_valid(enemy) or not enemy.visible:
			continue
		if enemy in exclude:
			continue
		var dist := from_pos.distance_to(enemy.global_position)
		if dist < best_dist:
			best_dist = dist
			best = enemy
	return best


## Get total chain count (base + level + synergy bonus, capped).
func _get_effective_chain_count() -> int:
	var base := base_chain_count
	if level >= 2:
		if upgrade_branch != "":
			var key := "level_%d" % level
			base = BRANCH_DATA.get(upgrade_branch, {}).get(key, {}).get("chain_count", base_chain_count)
		elif level <= UPGRADE_DATA.size():
			base = UPGRADE_DATA[level - 1].get("chain_count", base_chain_count)
	return mini(base + _chain_bonus, MAX_CHAIN_DEPTH)


## Get chain damage falloff (branch b has reduced falloff).
func _get_effective_chain_falloff() -> float:
	if upgrade_branch != "" and level >= 2:
		var key := "level_%d" % level
		return BRANCH_DATA.get(upgrade_branch, {}).get(key, {}).get("chain_falloff", CHAIN_DAMAGE_FALLOFF)
	return CHAIN_DAMAGE_FALLOFF


## Called by synergy calculator to set chain bonus from adjacent Arc Relays.
func set_chain_bonus(bonus: int) -> void:
	_chain_bonus = mini(bonus, 3)  # Max +3 from synergy


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

	## Draw chain lightning
	if _chain_flash_timer > 0 and _chain_points.size() > 0:
		var alpha := _chain_flash_timer / CHAIN_FLASH_DURATION
		var prev := Vector2.ZERO
		for point in _chain_points:
			## Jagged lightning effect
			var mid := (prev + point) * 0.5 + Vector2(
				randf_range(-8, 8), randf_range(-8, 8)
			)
			draw_line(prev, mid, Color(0.27, 0.53, 1, alpha), 2.0)
			draw_line(mid, point, Color(0.27, 0.53, 1, alpha), 2.0)
			prev = point
