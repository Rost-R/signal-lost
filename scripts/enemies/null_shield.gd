## ============================================================================
## NULL SHIELD
## ============================================================================
##
## Purpose: Enemy with a front shield / first-hit damage reduction.
## Requires debuff (Scrambler Dish) or bypass damage to deal with efficiently.
## The shield absorbs the first portion of each hit.
##
## @author Signal Lost Team
## @version 0.1.0
class_name NullShield
extends "res://scripts/enemies/enemy_base.gd"

## GridManagerScript inherited from EnemyBase via preload()


## ============================================================================
## CONSTANTS
## ============================================================================

const SHIELD_ABSORB_PERCENT := 50.0  # Absorbs 50% of each hit
const SHIELD_MAX_ABSORB := 15.0      # Max damage absorbed per hit


## ============================================================================
## STATE
## ============================================================================

var _shield_active: bool = true


## ============================================================================
## LIFECYCLE
## ============================================================================

func _init() -> void:
	enemy_id = "null_shield"
	enemy_name = "Null Shield"
	max_hp = 80.0
	base_speed = 65.0
	damage_to_core = 2
	armor = 3.0
	reward = 18
	enemy_color = Color(0.27, 0.27, 0.67)  # #4444AA — deep blue
	_size_scale = 0.75


## Override take_damage to apply front shield reduction.
func take_damage(amount: float) -> void:
	var effective := amount

	## Front shield absorbs a portion of each hit (unless debuffed)
	if _shield_active and _debuff_percent < 30.0:
		var absorbed := minf(effective * SHIELD_ABSORB_PERCENT / 100.0, SHIELD_MAX_ABSORB)
		effective -= absorbed

	## Apply armor reduction (parent handles debuff interaction)
	var current_armor := armor * (1.0 - _debuff_percent / 100.0)
	effective = maxf(effective - current_armor, 1.0)

	## Shield absorbs first (if any shield_hp from base)
	if shield_hp > 0:
		if effective <= shield_hp:
			shield_hp -= effective
			_hit_flash_timer = HIT_FLASH_DURATION
			queue_redraw()
			return
		else:
			effective -= shield_hp
			shield_hp = 0

	current_hp -= effective
	_hit_flash_timer = HIT_FLASH_DURATION

	if current_hp <= 0:
		_die()


## ============================================================================
## DRAWING
## ============================================================================

func _draw_enemy() -> void:
	var size := GridManagerScript.CELL_SIZE * _size_scale * 0.38
	var color := enemy_color

	if _hit_flash_timer > 0:
		color = Color.WHITE
	if _is_frozen:
		color = Color(0.53, 0.87, 1)

	## Diamond body
	var points := PackedVector2Array([
		Vector2(0, -size),
		Vector2(size, 0),
		Vector2(0, size),
		Vector2(-size, 0)
	])
	draw_colored_polygon(points, Color(color, 0.6))
	draw_polyline(points + PackedVector2Array([points[0]]), color, 1.5)

	## Front shield arc (if not debuffed enough)
	if _shield_active and _debuff_percent < 30.0:
		var shield_alpha := 0.4 * (1.0 - _debuff_percent / 100.0)
		draw_arc(Vector2.ZERO, size * 1.2, -PI * 0.6, PI * 0.6, 24, Color(0.3, 0.5, 1, shield_alpha), 2.5)

	_draw_hp_bar(size)
