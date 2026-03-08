## ============================================================================
## CORRUPTED CARRIER
## ============================================================================
##
## Purpose: Slow tank enemy. Absorbs damage and tests sustained DPS.
## High HP, high armor, slow speed.
##
## @author Signal Lost Team
## @version 0.1.0
class_name CorruptedCarrier
extends "res://scripts/enemies/enemy_base.gd"

## GridManagerScript inherited from EnemyBase via preload()


func _init() -> void:
	enemy_id = "corrupted_carrier"
	enemy_name = "Corrupted Carrier"
	max_hp = 120.0
	base_speed = 50.0
	damage_to_core = 2
	armor = 8.0
	reward = 15
	enemy_color = Color(1, 0.4, 0.27)  # #FF6644
	_size_scale = 0.9


## Override draw for heavy tank visual.
func _draw_enemy() -> void:
	var size := GridManagerScript.CELL_SIZE * _size_scale * 0.4
	var color := enemy_color

	if _hit_flash_timer > 0:
		color = Color.WHITE
	if _is_frozen:
		color = Color(0.53, 0.87, 1)

	## Octagon body — heavy and armored
	var points := PackedVector2Array()
	for i in 8:
		var angle := deg_to_rad(45 * i - 22.5)
		points.append(Vector2(cos(angle), sin(angle)) * size)
	draw_colored_polygon(points, Color(color, 0.7))
	draw_polyline(points + PackedVector2Array([points[0]]), color, 2.0)

	## Armor plating lines
	draw_line(Vector2(-size * 0.5, 0), Vector2(size * 0.5, 0), Color(color, 0.4), 1.5)
	draw_line(Vector2(0, -size * 0.5), Vector2(0, size * 0.5), Color(color, 0.4), 1.5)

	_draw_hp_bar(size)
