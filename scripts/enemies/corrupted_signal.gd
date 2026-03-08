## ============================================================================
## CORRUPTED SIGNAL
## ============================================================================
##
## Purpose: Medium enemy with energy shields. Requires focused fire.
## Counter: Pulse Emitter focused fire to break shield.
##
## @author Signal Lost Team
## @version 0.1.0
class_name CorruptedSignal
extends EnemyBase


func _init() -> void:
	enemy_id = "corrupted_signal"
	enemy_name = "Corrupted Signal"
	max_hp = 80.0
	base_speed = 70.0
	damage_to_core = 2
	armor = 5.0
	max_shield = 30.0
	shield_hp = 30.0
	reward = 15
	enemy_color = Color(1, 0.4, 0.27)  # #FF6644
	_size_scale = 0.8


## Override draw for unique shielded visual.
func _draw_enemy() -> void:
	var size := GridManager.CELL_SIZE * _size_scale * 0.4
	var color := enemy_color

	if _hit_flash_timer > 0:
		color = Color.WHITE
	if _is_frozen:
		color = Color(0.53, 0.87, 1)

	## Octagon body
	var points := PackedVector2Array()
	for i in 8:
		var angle := deg_to_rad(45 * i - 22.5)
		points.append(Vector2(cos(angle), sin(angle)) * size)
	draw_colored_polygon(points, Color(color, 0.7))
	draw_polyline(points + PackedVector2Array([points[0]]), color, 1.5)

	## Shield ring
	if shield_hp > 0:
		var shield_ratio := shield_hp / max_shield
		var shield_color := Color(0.3, 0.5, 1, 0.4 * shield_ratio)
		draw_arc(Vector2.ZERO, size * 1.3, 0, TAU * shield_ratio, 32, shield_color, 2.0)

	_draw_hp_bar(size)
	_draw_shield_bar(size)
