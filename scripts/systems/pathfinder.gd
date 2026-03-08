## ============================================================================
## PATHFINDER
## ============================================================================
##
## Purpose: Wraps Godot's AStarGrid2D for enemy pathfinding on the grid.
## Recalculates when towers are placed/removed.
##
## @author Signal Lost Team
## @version 0.1.0
class_name Pathfinder
extends Node


## ============================================================================
## STATE
## ============================================================================

var _astar: AStarGrid2D
var _grid_manager: GridManager


## ============================================================================
## PUBLIC API
## ============================================================================

## Initialize the pathfinder with a grid manager reference.
func setup(grid_manager: GridManager) -> void:
	_grid_manager = grid_manager
	_rebuild()
	_grid_manager.tower_placed.connect(_on_grid_changed)
	_grid_manager.tower_removed.connect(_on_grid_changed_remove)


## Get a path from spawn to core in world coordinates.
func get_path_to_core(spawn_pos: Vector2i) -> PackedVector2Array:
	if not _astar:
		return PackedVector2Array()

	var core := _grid_manager.core_position
	if core == Vector2i(-1, -1):
		return PackedVector2Array()

	var grid_path := _astar.get_id_path(spawn_pos, core)
	var world_path := PackedVector2Array()
	for cell in grid_path:
		world_path.append(_grid_manager.grid_to_world(cell))
	return world_path


## Check if a path exists from any spawn to core.
## Used to prevent blocking the path with towers.
func has_valid_path() -> bool:
	if _grid_manager.spawn_points.is_empty():
		return false
	for spawn in _grid_manager.spawn_points:
		var path := get_path_to_core(spawn)
		if path.is_empty():
			return false
	return true


## ============================================================================
## PRIVATE
## ============================================================================

func _rebuild() -> void:
	_astar = AStarGrid2D.new()
	_astar.region = Rect2i(0, 0, GridManager.GRID_WIDTH, GridManager.GRID_HEIGHT)
	_astar.cell_size = Vector2(1, 1)
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.update()

	## Mark non-walkable cells as solid
	for x in GridManager.GRID_WIDTH:
		for y in GridManager.GRID_HEIGHT:
			var pos := Vector2i(x, y)
			var cell := _grid_manager.get_cell(pos)
			if cell == GridManager.CellType.SLOT or \
			   cell == GridManager.CellType.TOWER or \
			   cell == GridManager.CellType.BLOCKED:
				_astar.set_point_solid(pos, true)


func _on_grid_changed(_grid_pos: Vector2i, _tower: Node2D) -> void:
	_rebuild()


func _on_grid_changed_remove(_grid_pos: Vector2i) -> void:
	_rebuild()
