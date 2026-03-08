## ============================================================================
## DATA LEECH
## ============================================================================
##
## Purpose: Slow but tanky elite enemy. High armor, high core damage.
## For MVP: No tower drain ability yet — just a tough, slow threat.
##
## @author Signal Lost Team
## @version 0.1.0
class_name DataLeech
extends "res://scripts/enemies/enemy_base.gd"

## GridManagerScript inherited from EnemyBase via preload()


func _init() -> void:
	enemy_id = "data_leech"
	enemy_name = "Data Leech"
	max_hp = 150.0
	base_speed = 40.0
	damage_to_core = 3
	armor = 10.0
	reward = 25
	enemy_color = Color(0.53, 0.27, 0.13)  # #884422
	_size_scale = 1.0


## Override draw for unique leech visual.
func _draw_enemy() -> void:
	var size := GridManagerScript.CELL_SIZE * _size_scale * 0.4
	var color := enemy_color

	if _hit_flash_timer > 0:
		color = Color.WHITE
	if _is_frozen:
		color = Color(0.53, 0.87, 1)

	## Blob/circle shape — slow and heavy
	draw_circle(Vector2.ZERO, size, Color(color, 0.7))
	draw_arc(Vector2.ZERO, size, 0, TAU, 32, color, 2.0)

	## Inner tendrils (4 lines radiating out)
	for i in 4:
		var angle := deg_to_rad(90 * i + 45)
		var p := Vector2(cos(angle), sin(angle)) * size * 0.6
		draw_line(Vector2.ZERO, p, Color(color, 0.5), 1.5)

	_draw_hp_bar(size)
