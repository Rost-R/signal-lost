## ============================================================================
## AMPLIFIER
## ============================================================================
##
## Purpose: Support tower that boosts all adjacent non-Amplifier towers.
## Does not attack. Cannot boost other Amplifiers (anti-exploit).
## Synergy: Effect doubles if surrounded by 3+ non-Amplifier towers.
##
## @author Signal Lost Team
## @version 0.1.0
class_name Amplifier
extends "res://scripts/towers/tower_base.gd"

## GridManagerScript inherited from TowerBase via preload()


## ============================================================================
## CONSTANTS
## ============================================================================

const UPGRADE_DATA := [
	{},
	{ "buff_damage": 0.30, "buff_speed": 0.15, "buff_range": 0.15, "cost": 120 },
	{ "buff_damage": 0.45, "buff_speed": 0.20, "buff_range": 0.20, "cost": 250 },
]


## ============================================================================
## STATE
## ============================================================================

var base_buff_damage: float = 0.20
var base_buff_speed: float = 0.10
var base_buff_range: float = 0.10
var _is_supercharged: bool = false  # True when surrounded by 3+ non-Amplifier towers


## ============================================================================
## LIFECYCLE
## ============================================================================

func _init() -> void:
	tower_id = "amplifier"
	tower_name = "Amplifier"
	base_damage = 0.0
	base_attack_speed = 0.0  # Not attack-based
	base_range = 1.5  # Only affects adjacent cells
	base_cost = 180
	tower_color = Color(1, 0.87, 0.27)  # #FFDD44


func _physics_process(_delta: float) -> void:
	## Amplifier doesn't attack — just redraws for visual pulse
	queue_redraw()


## ============================================================================
## BUFF CALCULATION
## ============================================================================

## Get the buff values this Amplifier provides to adjacent towers.
## Called by the synergy system in game_scene.gd.
func get_buff_values(neighbor_count: int) -> Dictionary:
	var dmg := _get_effective_buff("damage")
	var spd := _get_effective_buff("speed")
	var rng := _get_effective_buff("range")

	## Supercharge: double effect if surrounded by 3+ non-Amplifier towers
	_is_supercharged = neighbor_count >= 3
	if _is_supercharged:
		dmg *= 2.0
		spd *= 2.0
		rng *= 2.0

	return {
		"damage": dmg,
		"speed": spd,
		"range": rng
	}


func _get_effective_buff(stat: String) -> float:
	match stat:
		"damage":
			if level <= 1: return base_buff_damage
			return UPGRADE_DATA[level - 1].get("buff_damage", base_buff_damage)
		"speed":
			if level <= 1: return base_buff_speed
			return UPGRADE_DATA[level - 1].get("buff_speed", base_buff_speed)
		"range":
			if level <= 1: return base_buff_range
			return UPGRADE_DATA[level - 1].get("buff_range", base_buff_range)
		_:
			return 0.0


## ============================================================================
## STATS
## ============================================================================

func _get_level_stats() -> Dictionary:
	return {
		"damage": 0.0,
		"attack_speed": 0.0,
		"range": base_range
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

	## Draw boost aura (pulsing)
	var size := GridManagerScript.CELL_SIZE * 0.5
	var pulse: float = 0.3 + abs(sin(Time.get_ticks_msec() * 0.004)) * 0.3
	var aura_color := Color(1, 0.87, 0.27, pulse * 0.15)

	## Diamond-shaped aura pointing to 4 adjacent cells
	var aura_points := PackedVector2Array([
		Vector2(0, -size),
		Vector2(size, 0),
		Vector2(0, size),
		Vector2(-size, 0)
	])
	draw_colored_polygon(aura_points, aura_color)

	## Supercharge indicator — extra ring
	if _is_supercharged:
		draw_arc(Vector2.ZERO, size * 0.8, 0, TAU, 32, Color(1, 0.87, 0.27, pulse * 0.5), 2.0)

	## Arrow indicators pointing to adjacent cells
	var arrow_size := 6.0
	var arrow_dist := size * 0.6
	for i in 4:
		var angle := deg_to_rad(90 * i)
		var dir := Vector2(cos(angle), sin(angle))
		var tip := dir * arrow_dist
		var left := tip + Vector2(cos(angle + 2.5), sin(angle + 2.5)) * arrow_size
		var right := tip + Vector2(cos(angle - 2.5), sin(angle - 2.5)) * arrow_size
		draw_line(left, tip, Color(1, 0.87, 0.27, pulse), 1.5)
		draw_line(right, tip, Color(1, 0.87, 0.27, pulse), 1.5)
