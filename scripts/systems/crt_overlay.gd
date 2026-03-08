## ============================================================================
## CRT OVERLAY
## ============================================================================
##
## Purpose: Applies CRT post-processing shader as a full-screen overlay.
## Manages intensity via settings. Placed on the highest CanvasLayer
## so the effect covers everything (game world + HUD).
##
## @author Signal Lost Team
## @version 0.1.0
extends CanvasLayer


## ============================================================================
## CONSTANTS
## ============================================================================

const CRT_SHADER := preload("res://assets/shaders/crt.gdshader")
const DEFAULT_INTENSITY := 0.7


## ============================================================================
## STATE
## ============================================================================

var _color_rect: ColorRect
var _material: ShaderMaterial


## ============================================================================
## LIFECYCLE
## ============================================================================

func _ready() -> void:
	## Render on top of everything
	layer = 100

	## Create full-screen ColorRect with the CRT shader
	_color_rect = ColorRect.new()
	_color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_material = ShaderMaterial.new()
	_material.shader = CRT_SHADER
	_material.set_shader_parameter("intensity", DEFAULT_INTENSITY)
	_color_rect.material = _material

	add_child(_color_rect)


## ============================================================================
## PUBLIC API
## ============================================================================

## Set CRT effect intensity (0.0 = off, 1.0 = full).
func set_intensity(value: float) -> void:
	value = clampf(value, 0.0, 1.0)
	if _material:
		_material.set_shader_parameter("intensity", value)


## Get current intensity.
func get_intensity() -> float:
	if _material:
		return _material.get_shader_parameter("intensity")
	return DEFAULT_INTENSITY


## Toggle CRT effect on/off.
func toggle() -> void:
	if _color_rect:
		_color_rect.visible = not _color_rect.visible


## Enable/disable CRT effect.
func set_enabled(enabled: bool) -> void:
	if _color_rect:
		_color_rect.visible = enabled
