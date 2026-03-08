## ============================================================================
## MIRROR FRAGMENT
## ============================================================================
##
## Purpose: Splits into smaller copies after death. Breaks overkill builds
## by punishing single-target focus. Each fragment has reduced HP.
##
## @author Signal Lost Team
## @version 0.1.0
class_name MirrorFragment
extends "res://scripts/enemies/enemy_base.gd"

## GridManagerScript inherited from EnemyBase via preload()


## ============================================================================
## CONSTANTS
## ============================================================================

const SPLIT_COUNT := 2       # Number of fragments on death
const FRAGMENT_HP_RATIO := 0.4  # Each fragment gets 40% of parent HP
const FRAGMENT_SPEED_MULT := 1.3  # Fragments move faster
const FRAGMENT_SIZE_MULT := 0.6


## ============================================================================
## STATE
## ============================================================================

var _is_fragment: bool = false  # True if this is a split copy
var _split_generation: int = 0  # Prevents infinite splitting (max 1 split)


## ============================================================================
## LIFECYCLE
## ============================================================================

func _init() -> void:
	enemy_id = "mirror_fragment"
	enemy_name = "Mirror Fragment"
	max_hp = 60.0
	base_speed = 70.0
	damage_to_core = 1
	armor = 2.0
	reward = 12
	enemy_color = Color(0.8, 0.8, 1)  # #CCCCFF — reflective blue-white
	_size_scale = 0.7


## Override death to spawn fragments.
func _die() -> void:
	## Only split if this is not already a fragment (generation 0)
	if _split_generation == 0 and not _is_fragment:
		_spawn_fragments()
	## Call parent death (award scrap, emit signal)
	super._die()


## ============================================================================
## SPLITTING
## ============================================================================

func _spawn_fragments() -> void:
	for i in SPLIT_COUNT:
		var fragment: Node2D = duplicate()
		if fragment.has_method("_setup_as_fragment"):
			fragment._setup_as_fragment(_path, _path_index, position, current_hp)
		get_parent().add_child(fragment)
		## Add to enemies group
		fragment.add_to_group("enemies")
		## Offset position slightly so they don't stack
		var offset := Vector2(randf_range(-10, 10), randf_range(-10, 10))
		fragment.position = position + offset


## Configure this enemy as a split fragment.
func _setup_as_fragment(parent_path: PackedVector2Array, path_idx: int, spawn_pos: Vector2, parent_hp: float) -> void:
	_is_fragment = true
	_split_generation = 1
	_path = parent_path
	_path_index = path_idx
	position = spawn_pos
	max_hp = parent_hp * FRAGMENT_HP_RATIO
	current_hp = max_hp
	base_speed *= FRAGMENT_SPEED_MULT
	_size_scale *= FRAGMENT_SIZE_MULT
	reward = int(reward * 0.5)
	_total_path_length = _calculate_total_path_length()


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

	## Shard/crystal shape — irregular polygon
	var points := PackedVector2Array([
		Vector2(0, -size),
		Vector2(size * 0.7, -size * 0.3),
		Vector2(size * 0.5, size * 0.6),
		Vector2(-size * 0.3, size * 0.8),
		Vector2(-size * 0.8, size * 0.1)
	])
	draw_colored_polygon(points, Color(color, 0.6))
	draw_polyline(points + PackedVector2Array([points[0]]), color, 1.5)

	## Reflective glint
	if not _is_frozen:
		var glint := sin(Time.get_ticks_msec() * 0.005) * 0.3 + 0.5
		draw_circle(Vector2(size * 0.2, -size * 0.3), 2.0, Color(1, 1, 1, glint))

	_draw_hp_bar(size)
