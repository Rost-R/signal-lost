## ============================================================================
## GRID MANAGER
## ============================================================================
##
## Purpose: Manages the tower defense grid — placement slots, tower positions,
## adjacency queries for synergies, and coordinate conversions.
##
## The grid is a 2D array where each cell can be:
##   - EMPTY: walkable path for enemies
##   - SLOT: available for tower placement
##   - TOWER: occupied by a tower
##   - BLOCKED: impassable terrain
##   - CORE: relay core position
##   - SPAWN: enemy spawn point
##
## @author Signal Lost Team
## @version 0.1.0
class_name GridManager
extends Node2D


## ============================================================================
## SIGNALS
## ============================================================================

signal tower_placed(grid_pos: Vector2i, tower: Node2D)
signal tower_removed(grid_pos: Vector2i)
signal cell_hovered(grid_pos: Vector2i, cell_type: CellType)


## ============================================================================
## ENUMS
## ============================================================================

enum CellType {
	EMPTY,
	SLOT,
	TOWER,
	BLOCKED,
	CORE,
	SPAWN
}


## ============================================================================
## CONSTANTS
## ============================================================================

const CELL_SIZE := 64
const GRID_WIDTH := 16
const GRID_HEIGHT := 9


## ============================================================================
## STATE
## ============================================================================

## Grid data: Vector2i -> CellType
var _grid: Dictionary = {}

## Tower references: Vector2i -> tower Node2D
var _towers: Dictionary = {}

## Currently hovered cell
var _hovered_cell: Vector2i = Vector2i(-1, -1)

## Spawn points
var spawn_points: Array[Vector2i] = []

## Core position
var core_position: Vector2i = Vector2i(-1, -1)


## ============================================================================
## LIFECYCLE
## ============================================================================

func _ready() -> void:
	_initialize_default_grid()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var new_hover := world_to_grid(get_global_mouse_position())
		if new_hover != _hovered_cell:
			_hovered_cell = new_hover
			if is_valid_cell(new_hover):
				cell_hovered.emit(new_hover, get_cell(new_hover))
	queue_redraw()


func _draw() -> void:
	_draw_grid()


## ============================================================================
## PUBLIC API
## ============================================================================

## Convert world position to grid coordinates.
func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		floori(world_pos.x / CELL_SIZE),
		floori(world_pos.y / CELL_SIZE)
	)


## Convert grid coordinates to world position (center of cell).
func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * CELL_SIZE + CELL_SIZE * 0.5,
		grid_pos.y * CELL_SIZE + CELL_SIZE * 0.5
	)


## Check if grid position is within bounds.
func is_valid_cell(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < GRID_WIDTH and \
		   grid_pos.y >= 0 and grid_pos.y < GRID_HEIGHT


## Get cell type at position.
func get_cell(grid_pos: Vector2i) -> CellType:
	if not is_valid_cell(grid_pos):
		return CellType.BLOCKED
	return _grid.get(grid_pos, CellType.EMPTY)


## Check if a tower can be placed at this position.
func can_place_tower(grid_pos: Vector2i) -> bool:
	return is_valid_cell(grid_pos) and get_cell(grid_pos) == CellType.SLOT


## Place a tower on the grid.
func place_tower(grid_pos: Vector2i, tower: Node2D) -> bool:
	if not can_place_tower(grid_pos):
		return false
	_grid[grid_pos] = CellType.TOWER
	_towers[grid_pos] = tower
	tower.position = grid_to_world(grid_pos)
	tower_placed.emit(grid_pos, tower)
	queue_redraw()
	return true


## Remove a tower from the grid.
func remove_tower(grid_pos: Vector2i) -> Node2D:
	if get_cell(grid_pos) != CellType.TOWER:
		return null
	var tower: Node2D = _towers.get(grid_pos)
	_grid[grid_pos] = CellType.SLOT
	_towers.erase(grid_pos)
	tower_removed.emit(grid_pos)
	queue_redraw()
	return tower


## Get the tower at a grid position (or null).
func get_tower_at(grid_pos: Vector2i) -> Node2D:
	return _towers.get(grid_pos)


## Get all adjacent tower positions (4-directional).
func get_adjacent_towers(grid_pos: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var directions := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	for dir in directions:
		var check: Vector2i = grid_pos + dir
		if _towers.has(check):
			result.append(check)
	return result


## Get all adjacent towers as Node2D references.
func get_adjacent_tower_nodes(grid_pos: Vector2i) -> Array[Node2D]:
	var result: Array[Node2D] = []
	for pos in get_adjacent_towers(grid_pos):
		result.append(_towers[pos])
	return result


## Count adjacent towers of a specific type.
func count_adjacent_of_type(grid_pos: Vector2i, tower_id: String) -> int:
	var count := 0
	for tower in get_adjacent_tower_nodes(grid_pos):
		if tower.has_method("get_tower_id") and tower.get_tower_id() == tower_id:
			count += 1
	return count


## Count all adjacent non-amplifier towers.
func count_adjacent_non_amplifier(grid_pos: Vector2i) -> int:
	var count := 0
	for tower in get_adjacent_tower_nodes(grid_pos):
		if tower.has_method("get_tower_id") and tower.get_tower_id() != "amplifier":
			count += 1
	return count


## Get all placed tower positions.
func get_all_tower_positions() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for pos in _towers.keys():
		result.append(pos)
	return result


## Get all cells of a specific type.
func get_cells_of_type(cell_type: CellType) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for pos in _grid:
		if _grid[pos] == cell_type:
			result.append(pos)
	return result


## Get all walkable cells (EMPTY) for pathfinding.
func get_walkable_cells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for x in GRID_WIDTH:
		for y in GRID_HEIGHT:
			var pos := Vector2i(x, y)
			var cell := get_cell(pos)
			if cell == CellType.EMPTY or cell == CellType.SPAWN or cell == CellType.CORE:
				result.append(pos)
	return result


## Set a cell type directly (for map generation).
func set_cell(grid_pos: Vector2i, cell_type: CellType) -> void:
	if is_valid_cell(grid_pos):
		_grid[grid_pos] = cell_type
		if cell_type == CellType.CORE:
			core_position = grid_pos
		elif cell_type == CellType.SPAWN:
			if grid_pos not in spawn_points:
				spawn_points.append(grid_pos)
		queue_redraw()


## ============================================================================
## GRID DRAWING
## ============================================================================

func _draw_grid() -> void:
	## Draw cell backgrounds
	for x in GRID_WIDTH:
		for y in GRID_HEIGHT:
			var pos := Vector2i(x, y)
			var rect := Rect2(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
			var cell := get_cell(pos)

			match cell:
				CellType.EMPTY:
					pass  # Transparent
				CellType.SLOT:
					draw_rect(rect, Color(0, 1, 0.53, 0.05))  # Subtle green
				CellType.TOWER:
					draw_rect(rect, Color(0, 0.78, 1, 0.1))  # Subtle cyan
				CellType.BLOCKED:
					draw_rect(rect, Color(1, 1, 1, 0.03))
				CellType.CORE:
					draw_rect(rect, Color(0.67, 0.27, 1, 0.15))  # Purple
				CellType.SPAWN:
					draw_rect(rect, Color(1, 0.13, 0.27, 0.1))  # Red

	## Draw grid lines
	var grid_color := Color(0, 1, 0.53, 0.08)  # Very subtle green
	for x in GRID_WIDTH + 1:
		draw_line(
			Vector2(x * CELL_SIZE, 0),
			Vector2(x * CELL_SIZE, GRID_HEIGHT * CELL_SIZE),
			grid_color, 1.0
		)
	for y in GRID_HEIGHT + 1:
		draw_line(
			Vector2(0, y * CELL_SIZE),
			Vector2(GRID_WIDTH * CELL_SIZE, y * CELL_SIZE),
			grid_color, 1.0
		)

	## Draw hover highlight
	if is_valid_cell(_hovered_cell):
		var hover_rect := Rect2(
			_hovered_cell.x * CELL_SIZE, _hovered_cell.y * CELL_SIZE,
			CELL_SIZE, CELL_SIZE
		)
		var hover_color: Color
		match get_cell(_hovered_cell):
			CellType.SLOT:
				hover_color = Color(0, 1, 0.53, 0.2)  # Green — can place
			CellType.TOWER:
				hover_color = Color(0, 0.78, 1, 0.2)  # Cyan — has tower
			_:
				hover_color = Color(1, 0.13, 0.27, 0.15)  # Red — can't place
		draw_rect(hover_rect, hover_color)


## ============================================================================
## DEFAULT MAP (MVP — fixed layout)
## ============================================================================

func _initialize_default_grid() -> void:
	## Fill everything as EMPTY first
	for x in GRID_WIDTH:
		for y in GRID_HEIGHT:
			_grid[Vector2i(x, y)] = CellType.EMPTY

	## Define path (enemy walkway) — S-shaped path from left to right
	## Path is EMPTY cells, tower slots are on the sides

	## Place tower slots in a strategic pattern
	var slot_positions: Array[Vector2i] = [
		# Top row slots
		Vector2i(3, 1), Vector2i(5, 1), Vector2i(7, 1), Vector2i(9, 1), Vector2i(11, 1),
		# Upper-mid slots
		Vector2i(2, 3), Vector2i(4, 3), Vector2i(6, 3), Vector2i(8, 3), Vector2i(10, 3), Vector2i(12, 3),
		# Lower-mid slots
		Vector2i(3, 5), Vector2i(5, 5), Vector2i(7, 5), Vector2i(9, 5), Vector2i(11, 5),
		# Bottom row slots
		Vector2i(2, 7), Vector2i(4, 7), Vector2i(6, 7), Vector2i(8, 7), Vector2i(10, 7), Vector2i(12, 7),
	]

	for slot_pos in slot_positions:
		set_cell(slot_pos, CellType.SLOT)

	## Set spawn point (left edge)
	set_cell(Vector2i(0, 4), CellType.SPAWN)

	## Set core position (right side)
	set_cell(Vector2i(14, 4), CellType.CORE)

	## Set some blocked terrain for visual variety
	var blocked := [
		Vector2i(6, 0), Vector2i(7, 0), Vector2i(8, 0),
		Vector2i(6, 8), Vector2i(7, 8), Vector2i(8, 8),
	]
	for pos in blocked:
		set_cell(pos, CellType.BLOCKED)
