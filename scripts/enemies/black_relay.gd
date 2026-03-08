## ============================================================================
## BLACK RELAY (BOSS 2)
## ============================================================================
##
## Purpose: Second boss. Calls EMP pulses that temporarily disable nearby
## towers. Tests backup builds and resilience.
##
## @author Signal Lost Team
## @version 0.1.0
class_name BlackRelay
extends "res://scripts/enemies/enemy_base.gd"

## GridManagerScript inherited from EnemyBase via preload()


## ============================================================================
## CONSTANTS
## ============================================================================

const EMP_INTERVAL := 8.0         # Seconds between EMP pulses
const EMP_RANGE_PX := 192.0       # 3 cells
const EMP_DISABLE_DURATION := 3.0 # Seconds towers are disabled
const EMP_FLASH_DURATION := 0.3


## ============================================================================
## STATE
## ============================================================================

var _emp_timer: float = EMP_INTERVAL
var _emp_flash_timer: float = 0.0


## ============================================================================
## LIFECYCLE
## ============================================================================

func _init() -> void:
	enemy_id = "black_relay"
	enemy_name = "Black Relay"
	max_hp = 3000.0
	base_speed = 22.0
	damage_to_core = 12
	armor = 20.0
	reward = 300
	enemy_color = Color(0.15, 0.15, 0.2)  # Near-black with blue tint
	_size_scale = 2.0


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	## EMP pulse logic
	if visible and not _is_frozen:
		_emp_timer -= delta
		if _emp_timer <= 0:
			_fire_emp()
			_emp_timer = EMP_INTERVAL

	if _emp_flash_timer > 0:
		_emp_flash_timer -= delta
		queue_redraw()


## ============================================================================
## EMP PULSE
## ============================================================================

## Fire an EMP that disables nearby towers temporarily.
## For MVP: towers in range stop attacking for EMP_DISABLE_DURATION.
func _fire_emp() -> void:
	_emp_flash_timer = EMP_FLASH_DURATION

	## Find towers in EMP range and disable them
	var towers := get_tree().get_nodes_in_group("towers")
	for tower in towers:
		if not is_instance_valid(tower):
			continue
		var dist := global_position.distance_to(tower.global_position)
		if dist <= EMP_RANGE_PX:
			## Disable tower by resetting its attack timer backward
			if "_attack_timer" in tower:
				tower._attack_timer = -EMP_DISABLE_DURATION


## ============================================================================
## DRAWING
## ============================================================================

func _draw_enemy() -> void:
	var size := GridManagerScript.CELL_SIZE * _size_scale * 0.4
	var color := enemy_color

	if _hit_flash_timer > 0:
		color = Color.WHITE
	if _is_frozen:
		color = Color(0.53, 0.87, 1)

	## HP-based intensity
	var hp_ratio := clampf(current_hp / max_hp, 0.0, 1.0)
	if hp_ratio < 0.33:
		color = color.lerp(Color(1, 0, 0.3), 0.4)

	## Dark pulsing aura
	var pulse := sin(Time.get_ticks_msec() * 0.003) * 0.15 + 0.85
	draw_arc(Vector2.ZERO, size * 1.6 * pulse, 0, TAU, 48, Color(0.3, 0.1, 0.5, 0.2), 3.0)

	## EMP blast ring (expanding on fire)
	if _emp_flash_timer > 0:
		var emp_alpha := _emp_flash_timer / EMP_FLASH_DURATION
		var emp_radius := EMP_RANGE_PX * (1.0 - emp_alpha * 0.3)
		draw_arc(Vector2.ZERO, emp_radius, 0, TAU, 48, Color(0.5, 0.2, 1, emp_alpha * 0.4), 3.0)
		draw_arc(Vector2.ZERO, emp_radius * 0.6, 0, TAU, 32, Color(0.5, 0.2, 1, emp_alpha * 0.2), 2.0)

	## Pentagon boss body — distinct from The Choir's hexagon
	var points := PackedVector2Array()
	for i in 5:
		var angle := deg_to_rad(72 * i - 90)
		points.append(Vector2(cos(angle), sin(angle)) * size)
	draw_colored_polygon(points, Color(color, 0.7))
	draw_polyline(points + PackedVector2Array([points[0]]), Color(0.5, 0.2, 1), 3.0)

	## Inner void core
	draw_circle(Vector2.ZERO, size * 0.35, Color(0, 0, 0, 0.8))
	draw_arc(Vector2.ZERO, size * 0.35, 0, TAU, 24, Color(0.5, 0.2, 1, 0.6), 1.5)

	## EMP charge indicator
	var charge := 1.0 - (_emp_timer / EMP_INTERVAL)
	if charge > 0.6:
		var c_alpha := (charge - 0.6) / 0.4
		draw_arc(Vector2.ZERO, size * 0.5, 0, TAU * charge, 24, Color(0.5, 0.2, 1, c_alpha * 0.5), 2.0)

	_draw_hp_bar(size)
