## ============================================================================
## GLITCH SWARM
## ============================================================================
##
## Purpose: Fast, low HP enemy that comes in masses.
## Counter: Arc Relay chain lightning, area damage.
##
## @author Signal Lost Team
## @version 0.1.0
class_name GlitchSwarm
extends EnemyBase


func _init() -> void:
	enemy_id = "glitch_swarm"
	enemy_name = "Glitch Swarm"
	max_hp = 30.0
	base_speed = 120.0
	damage_to_core = 1
	armor = 0.0
	reward = 8
	enemy_color = Color(1, 0.13, 0.27)  # #FF2244
	_size_scale = 0.5


## Override draw for unique glitch visual.
func _draw_enemy() -> void:
	var size := GridManager.CELL_SIZE * _size_scale * 0.35
	var color := enemy_color

	if _hit_flash_timer > 0:
		color = Color.WHITE
	if _is_frozen:
		color = Color(0.53, 0.87, 1)

	## Glitchy triangle shape
	var jitter := Vector2(randf_range(-2, 2), randf_range(-2, 2)) if not _is_frozen else Vector2.ZERO
	var points := PackedVector2Array([
		Vector2(0, -size) + jitter,
		Vector2(size * 0.8, size * 0.6),
		Vector2(-size * 0.8, size * 0.6)
	])
	draw_colored_polygon(points, Color(color, 0.7))
	draw_polyline(points + PackedVector2Array([points[0]]), color, 1.0)

	_draw_hp_bar(size)
