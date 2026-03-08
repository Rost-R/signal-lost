## ============================================================================
## PHANTOM BURST
## ============================================================================
##
## Purpose: Fast elite enemy with low HP but high core damage.
## For MVP: Semi-transparent visual to hint at stealth. No teleport yet.
##
## @author Signal Lost Team
## @version 0.1.0
class_name PhantomBurst
extends "res://scripts/enemies/enemy_base.gd"

## GridManagerScript inherited from EnemyBase via preload()


func _init() -> void:
	enemy_id = "phantom_burst"
	enemy_name = "Phantom Burst"
	max_hp = 60.0
	base_speed = 90.0
	damage_to_core = 4
	armor = 0.0
	reward = 30
	enemy_color = Color(0.27, 0.27, 0.67)  # #4444AA
	_size_scale = 0.7


## Override draw for ghostly/phasing visual.
func _draw_enemy() -> void:
	var size := GridManagerScript.CELL_SIZE * _size_scale * 0.35
	var color := enemy_color

	if _hit_flash_timer > 0:
		color = Color.WHITE
	if _is_frozen:
		color = Color(0.53, 0.87, 1)

	## Phase-shifted diamond — semi-transparent with offset echo
	var points := PackedVector2Array([
		Vector2(0, -size),
		Vector2(size, 0),
		Vector2(0, size),
		Vector2(-size, 0)
	])

	## Ghost echo (offset copy)
	var echo_offset := Vector2(3, -3)
	var echo_points := PackedVector2Array()
	for p in points:
		echo_points.append(p + echo_offset)
	draw_colored_polygon(echo_points, Color(color, 0.2))

	## Main body
	draw_colored_polygon(points, Color(color, 0.5))
	draw_polyline(points + PackedVector2Array([points[0]]), Color(color, 0.8), 1.5)

	_draw_hp_bar(size)
