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

const BASE_BEAM_WIDTH := 10.0
const BEAM_FLASH_DURATION := 0.2

## ============================================================================
## STATE
## ============================================================================

var _beam_flash_timer: float = 0.0
var _beam_direction: Vector2 = Vector2.ZERO
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

	## Direction from tower to primary target
	var dir := (target.global_position - global_position).normalized()

	## Find all enemies along the beam line
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not is_instance_valid(enemy) or not enemy.visible:
			continue
		## Check if enemy is within beam width of the line
		var to_enemy := enemy.global_position - global_position
		var proj := to_enemy.dot(dir)
		if proj < 0 or proj > range_px:
			continue
		var perp_dist := abs(to_enemy.cross(dir))
		if perp_dist <= beam_w * 0.5:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)

	## Visual beam
	_beam_direction = dir
	_beam_length = range_px
	_beam_flash_timer = BEAM_FLASH_DURATION


## Get effective beam width for current level.
func _get_effective_beam_width() -> float:
	if level <= 1:
		return BASE_BEAM_WIDTH
	return UPGRADE_DATA[level - 1].get("beam_width", BASE_BEAM_WIDTH)


## ============================================================================
## STATS
## ============================================================================

func _get_level_stats() -> Dictionary:
	if level <= 1:
		return {
			"damage": base_damage,
			"attack_speed": base_attack_speed,
			"range": base_range
		}
	var data: Dictionary = UPGRADE_DATA[level - 1]
	return {
		"damage": data.get("damage", base_damage),
		"attack_speed": data.get("attack_speed", base_attack_speed),
		"range": data.get("range", base_range)
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

	## Draw piercing beam
	if _beam_flash_timer > 0 and _beam_direction != Vector2.ZERO:
		var alpha := _beam_flash_timer / BEAM_FLASH_DURATION
		var beam_end := _beam_direction * _beam_length
		var beam_w := _get_effective_beam_width()
		## Main beam — wide golden line
		draw_line(Vector2.ZERO, beam_end, Color(1, 0.84, 0, alpha), beam_w * 0.5)
		## Core — bright white center
		draw_line(Vector2.ZERO, beam_end, Color(1, 1, 0.9, alpha * 0.8), 2.0)
