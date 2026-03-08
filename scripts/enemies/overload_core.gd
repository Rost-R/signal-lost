## ============================================================================
## OVERLOAD CORE (BOSS)
## ============================================================================
##
## Purpose: Wave 8 boss. Massive HP, high armor, devastating core damage.
## For MVP: Big and slow with visual phases. No minion spawning yet.
##
## @author Signal Lost Team
## @version 0.1.0
class_name OverloadCore
extends "res://scripts/enemies/enemy_base.gd"

## GridManagerScript inherited from EnemyBase via preload()


func _init() -> void:
	enemy_id = "overload_core"
	enemy_name = "Overload Core"
	max_hp = 2000.0
	base_speed = 25.0
	damage_to_core = 10
	armor = 20.0
	reward = 200
	enemy_color = Color(0.67, 0.27, 1)  # #AA44FF
	_size_scale = 1.8


## Override draw for massive boss visual.
func _draw_enemy() -> void:
	var size := GridManagerScript.CELL_SIZE * _size_scale * 0.4
	var color := enemy_color

	if _hit_flash_timer > 0:
		color = Color.WHITE
	if _is_frozen:
		color = Color(0.53, 0.87, 1)

	## HP-based color shift (gets angrier at low HP)
	var hp_ratio := clampf(current_hp / max_hp, 0.0, 1.0)
	if hp_ratio < 0.33:
		color = color.lerp(Color(1, 0.13, 0.27), 0.5)
	elif hp_ratio < 0.66:
		color = color.lerp(Color(1, 0.73, 0), 0.3)

	## Pulsing outer aura
	var pulse := sin(Time.get_ticks_msec() * 0.004) * 0.1 + 0.9
	draw_arc(Vector2.ZERO, size * 1.5 * pulse, 0, TAU, 48, Color(color, 0.15), 2.0)

	## Hexagonal boss body
	var points := PackedVector2Array()
	for i in 6:
		var angle := deg_to_rad(60 * i)
		points.append(Vector2(cos(angle), sin(angle)) * size)
	draw_colored_polygon(points, Color(color, 0.6))
	draw_polyline(points + PackedVector2Array([points[0]]), color, 3.0)

	## Inner core glow
	draw_circle(Vector2.ZERO, size * 0.3, Color(color, 0.8 * pulse))

	## Phase indicators (dots at 66% and 33% thresholds)
	if hp_ratio > 0.66:
		draw_circle(Vector2(-8, size + 8), 3.0, color)
		draw_circle(Vector2(0, size + 8), 3.0, color)
		draw_circle(Vector2(8, size + 8), 3.0, color)
	elif hp_ratio > 0.33:
		draw_circle(Vector2(-4, size + 8), 3.0, color)
		draw_circle(Vector2(4, size + 8), 3.0, color)
	else:
		draw_circle(Vector2(0, size + 8), 3.0, Color(1, 0.13, 0.27))

	_draw_hp_bar(size)
