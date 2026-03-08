## ============================================================================
## RELAY CORE
## ============================================================================
##
## Purpose: The thing you're defending. Visual representation of the relay
## core on the grid. Pulses and changes color based on HP.
##
## @author Signal Lost Team
## @version 0.1.0
class_name RelayCore
extends Node2D

## Preload scripts to avoid class_name resolution issues
const GridManagerScript = preload("res://scripts/systems/grid_manager.gd")


## ============================================================================
## STATE
## ============================================================================

var _pulse_phase: float = 0.0


## ============================================================================
## LIFECYCLE
## ============================================================================

func _process(delta: float) -> void:
	_pulse_phase += delta * 2.0
	queue_redraw()


func _draw() -> void:
	var hp_ratio := 1.0
	if GameManager.STARTING_CORE_HP > 0:
		hp_ratio = clampf(float(GameManager.core_hp) / GameManager.STARTING_CORE_HP, 0.0, 1.0)

	var size := GridManagerScript.CELL_SIZE * 0.4
	var pulse := sin(_pulse_phase) * 0.15 + 0.85

	## Color shifts from purple (healthy) to red (damaged)
	var base_color := Color(0.67, 0.27, 1.0)  # Purple
	var danger_color := Color(1.0, 0.13, 0.27)  # Red
	var color := base_color.lerp(danger_color, 1.0 - hp_ratio)

	## Outer rings (pulse)
	draw_arc(Vector2.ZERO, size * 1.8 * pulse, 0, TAU, 64, Color(color, 0.1), 1.0)
	draw_arc(Vector2.ZERO, size * 1.4 * pulse, 0, TAU, 48, Color(color, 0.2), 1.0)

	## Core body — diamond
	var points := PackedVector2Array([
		Vector2(0, -size),
		Vector2(size, 0),
		Vector2(0, size),
		Vector2(-size, 0)
	])
	draw_colored_polygon(points, Color(color, 0.6 * pulse))
	draw_polyline(points + PackedVector2Array([points[0]]), Color(color, 0.9), 2.0)

	## Inner glow
	draw_circle(Vector2.ZERO, size * 0.3, Color(color, 0.8 * pulse))

	## HP text
	var font := ThemeDB.fallback_font
	if font:
		var hp_text := str(GameManager.core_hp)
		var text_size := font.get_string_size(hp_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14)
		draw_string(font, Vector2(-text_size.x * 0.5, size + 16), hp_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, color)
