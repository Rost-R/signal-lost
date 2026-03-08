## ============================================================================
## SCRAMBLER DISH
## ============================================================================
##
## Purpose: Debuff / anti-shield / resistance break tower. Opens damage windows
## by reducing enemy defense. Weak raw DPS but essential against elites and bosses.
## Synergy: Adjacent Pulse Emitters get +20% damage (applied in game_scene.gd).
##
## @author Signal Lost Team
## @version 0.1.0
class_name ScramblerDish
extends "res://scripts/towers/tower_base.gd"


## ============================================================================
## CONSTANTS
## ============================================================================

const UPGRADE_DATA := [
	{},
	{ "damage": 12.0, "attack_speed": 1.1, "range": 3.5, "debuff_percent": 35.0, "debuff_duration": 3.5, "cost": 120 },
	{ "damage": 18.0, "attack_speed": 1.3, "range": 4.0, "debuff_percent": 50.0, "debuff_duration": 4.0, "cost": 165 },
]

const DEBUFF_FLASH_DURATION := 0.12

## ============================================================================
## STATE
## ============================================================================

var base_debuff_percent: float = 25.0  # Armor/resistance reduction
var base_debuff_duration: float = 3.0  # Seconds
var _debuff_flash_timer: float = 0.0
var _last_target_pos: Vector2 = Vector2.ZERO


## ============================================================================
## LIFECYCLE
## ============================================================================

func _init() -> void:
	tower_id = "scrambler_dish"
	tower_name = "Scrambler Dish"
	base_damage = 8.0
	base_attack_speed = 0.9
	base_range = 3.0
	base_cost = 75
	power_cost = 1
	tower_color = Color(0.86, 0.44, 1)  # #DB70FF — purple


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _debuff_flash_timer > 0:
		_debuff_flash_timer -= delta
		queue_redraw()


## ============================================================================
## ATTACK
## ============================================================================

func _attack(target: Node2D) -> void:
	var damage := effective_damage

	if target.has_method("take_damage"):
		target.take_damage(damage)

	## Apply resistance debuff
	if target.has_method("apply_debuff"):
		target.apply_debuff(_get_effective_debuff_percent(), _get_effective_debuff_duration())

	## Visual
	_last_target_pos = target.global_position - global_position
	_debuff_flash_timer = DEBUFF_FLASH_DURATION


## Get effective debuff percent for current level.
func _get_effective_debuff_percent() -> float:
	if level <= 1:
		return base_debuff_percent
	return UPGRADE_DATA[level - 1].get("debuff_percent", base_debuff_percent)


## Get effective debuff duration for current level.
func _get_effective_debuff_duration() -> float:
	if level <= 1:
		return base_debuff_duration
	return UPGRADE_DATA[level - 1].get("debuff_duration", base_debuff_duration)


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

	## Draw debuff beam flash when attacking
	if _debuff_flash_timer > 0 and _last_target_pos != Vector2.ZERO:
		var alpha := _debuff_flash_timer / DEBUFF_FLASH_DURATION
		## Dashed-style double line to distinguish from Pulse Emitter
		draw_line(Vector2.ZERO, _last_target_pos, Color(0.86, 0.44, 1, alpha), 1.5)
		var mid := _last_target_pos * 0.5
		draw_circle(mid, 4.0, Color(0.86, 0.44, 1, alpha * 0.6))
