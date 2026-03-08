## ============================================================================
## PHASE LEECH
## ============================================================================
##
## Purpose: Teleport/phase-step enemy. Periodically blinks forward along
## its path, skipping past towers. Punishes linear kill zones.
##
## @author Signal Lost Team
## @version 0.1.0
class_name PhaseLeech
extends "res://scripts/enemies/enemy_base.gd"

## GridManagerScript inherited from EnemyBase via preload()


## ============================================================================
## CONSTANTS
## ============================================================================

const PHASE_COOLDOWN := 4.0        # Seconds between teleports
const PHASE_DISTANCE := 2          # Path points to skip
const PHASE_FLASH_DURATION := 0.2


## ============================================================================
## STATE
## ============================================================================

var _phase_timer: float = PHASE_COOLDOWN
var _phase_flash_timer: float = 0.0


## ============================================================================
## LIFECYCLE
## ============================================================================

func _init() -> void:
	enemy_id = "phase_leech"
	enemy_name = "Phase Leech"
	max_hp = 50.0
	base_speed = 80.0
	damage_to_core = 3
	armor = 0.0
	reward = 22
	enemy_color = Color(0.4, 0.8, 0.6)  # #66CC99 — teal/green
	_size_scale = 0.6


func _physics_process(delta: float) -> void:
	## Phase teleport logic (before parent movement)
	if not _is_frozen and _path.size() > 0 and _path_index < _path.size():
		_phase_timer -= delta
		if _phase_timer <= 0:
			_execute_phase()
			_phase_timer = PHASE_COOLDOWN

	if _phase_flash_timer > 0:
		_phase_flash_timer -= delta

	super._physics_process(delta)


## ============================================================================
## PHASE TELEPORT
## ============================================================================

func _execute_phase() -> void:
	var new_index := mini(_path_index + PHASE_DISTANCE, _path.size() - 1)
	if new_index > _path_index:
		_path_index = new_index
		position = _path[_path_index]
		_phase_flash_timer = PHASE_FLASH_DURATION

		## Check if we reached the end
		if _path_index >= _path.size() - 1:
			_reach_core()


## ============================================================================
## DRAWING
## ============================================================================

func _draw_enemy() -> void:
	var size := GridManagerScript.CELL_SIZE * _size_scale * 0.35
	var color := enemy_color

	if _hit_flash_timer > 0:
		color = Color.WHITE
	if _is_frozen:
		color = Color(0.53, 0.87, 1)

	## Phase flash effect
	if _phase_flash_timer > 0:
		var flash_alpha := _phase_flash_timer / PHASE_FLASH_DURATION
		draw_arc(Vector2.ZERO, size * 2.0, 0, TAU, 24, Color(0.4, 0.8, 0.6, flash_alpha * 0.5), 2.0)

	## Elongated diamond — sleek and fast
	var points := PackedVector2Array([
		Vector2(0, -size * 1.3),
		Vector2(size * 0.6, 0),
		Vector2(0, size * 1.3),
		Vector2(-size * 0.6, 0)
	])
	draw_colored_polygon(points, Color(color, 0.5))
	draw_polyline(points + PackedVector2Array([points[0]]), Color(color, 0.8), 1.5)

	## Phase charge indicator
	var charge := 1.0 - (_phase_timer / PHASE_COOLDOWN)
	if charge > 0.5:
		draw_circle(Vector2.ZERO, 3.0, Color(0.4, 0.8, 0.6, charge * 0.6))

	_draw_hp_bar(size)
