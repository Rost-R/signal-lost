## ============================================================================
## GRID MANAGER
## ============================================================================
##
## Purpose: Manages the tower defense grid — placement slots, tower positions,
## adjacency queries for synergies, and coordinate conversions.
## Supports loading different sector layouts from sectors.json.
##
## Cell types:
##   EMPTY: walkable path for enemies
##   SLOT: available for tower placement
##   TOWER: occupied by a tower
##   BLOCKED: impassable terrain
##   CORE: relay core position
##   SPAWN: enemy spawn point
##
## Special node overlays (on SLOT cells):
##   POWER_NODE: +1 power cap when tower placed here
##   HAZARD_NODE: enemies passing nearby get speed boost
##   RELAY_NODE: towers here get +15% range
##
## @author Signal Lost Team
## @version 0.2.0
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

enum NodeType {
	NONE,
	POWER,
	HAZARD,
	RELAY
}


## ============================================================================
## CONSTANTS
## ============================================================================

const CELL_SIZE := 64
const GRID_WIDTH := 16
const GRID_HEIGHT := 9

## Special node colors
const POWER_NODE_COLOR := Color(1, 0.72, 0, 0.2)  # Amber
const HAZARD_NODE_COLOR := Color(1, 0.13, 0.27, 0.15)  # Red
const RELAY_NODE_COLOR := Color(0, 0.78, 1, 0.15)  # Cyan


## ============================================================================
## STATE
## ============================================================================

## Grid data: Vector2i -> CellType
var _grid: Dictionary = {}

## Special node overlays: Vector2i -> NodeType
var _nodes: Dictionary = {}

## Tower references: Vector2i -> tower Node2D
var _towers: Dictionary = {}

## Currently hovered cell
var _hovered_cell: Vector2i = Vector2i(-1, -1)

## Spawn points
var spawn_points: Array[Vector2i] = []

## Core position
var core_position: Vector2i = Vector2i(-1, -1)

## Current sector info
var current_sector_id: String = ""
var current_sector_name: String = ""

## Sector data loaded from JSON
var _sector_data: Dictionary = {}


## ============================================================================
## LIFECYCLE
## ============================================================================

func _ready() -> void:
	_load_sector_data()
	## Default sector loaded by game_scene via load_sector()
	## If no sector is loaded externally, fall back to relay_spine
	if current_sector_id == "":
		load_sector("relay_spine")


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
## SECTOR LOADING
## ============================================================================

## Load sector definitions from JSON.
func _load_sector_data() -> void:
	var file := FileAccess.open("res://data/sectors.json", FileAccess.READ)
	if not file:
		push_warning("GridManager: sectors.json not found, using default layout")
		return
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_warning("GridManager: Failed to parse sectors.json")
		return
	_sector_data = json.data.get("sectors", {})


## Load a specific sector by ID. Clears any existing grid state.
func load_sector(sector_id: String) -> void:
	_clear_grid()

	var sector: Dictionary = _sector_data.get(sector_id, {})
	if sector.is_empty():
		push_warning("GridManager: Sector '%s' not found, using relay_spine" % sector_id)
		sector = _sector_data.get("relay_spine", {})
		sector_id = "relay_spine"

	current_sector_id = sector_id
	current_sector_name = sector.get("name", sector_id)

	## Fill grid with EMPTY
	for x in GRID_WIDTH:
		for y in GRID_HEIGHT:
			_grid[Vector2i(x, y)] = CellType.EMPTY

	## Place slots
	for slot_arr in sector.get("slots", []):
		set_cell(Vector2i(int(slot_arr[0]), int(slot_arr[1])), CellType.SLOT)

	## Place blocked terrain
	for blocked_arr in sector.get("blocked", []):
		set_cell(Vector2i(int(blocked_arr[0]), int(blocked_arr[1])), CellType.BLOCKED)

	## Set spawn points
	for sp_arr in sector.get("spawn_points", []):
		set_cell(Vector2i(int(sp_arr[0]), int(sp_arr[1])), CellType.SPAWN)

	## Set core position
	var core_arr: Array = sector.get("core_position", [14, 4])
	set_cell(Vector2i(int(core_arr[0]), int(core_arr[1])), CellType.CORE)

	## Set special nodes
	for pn_arr in sector.get("power_nodes", []):
		_nodes[Vector2i(int(pn_arr[0]), int(pn_arr[1]))] = NodeType.POWER
	for hn_arr in sector.get("hazard_nodes", []):
		_nodes[Vector2i(int(hn_arr[0]), int(hn_arr[1]))] = NodeType.HAZARD
	for rn_arr in sector.get("relay_nodes", []):
		_nodes[Vector2i(int(rn_arr[0]), int(rn_arr[1]))] = NodeType.RELAY

	queue_redraw()


## Clear all grid state for fresh sector load.
func _clear_grid() -> void:
	_grid.clear()
	_nodes.clear()
	_towers.clear()
	spawn_points.clear()
	core_position = Vector2i(-1, -1)


## Get list of available sector IDs.
func get_available_sectors() -> Array[String]:
	var result: Array[String] = []
	for key in _sector_data.keys():
		result.append(key)
	return result


## Get sector info dictionary (name, description, difficulty).
func get_sector_info(sector_id: String) -> Dictionary:
	return _sector_data.get(sector_id, {})


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


## Get special node type at position.
func get_node_type(grid_pos: Vector2i) -> NodeType:
	return _nodes.get(grid_pos, NodeType.NONE)


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

			## Draw special node overlays
			var node_type := get_node_type(pos)
			if node_type != NodeType.NONE:
				var node_color: Color
				var icon_char: String
				match node_type:
					NodeType.POWER:
						node_color = POWER_NODE_COLOR
						icon_char = "P"
					NodeType.HAZARD:
						node_color = HAZARD_NODE_COLOR
						icon_char = "!"
					NodeType.RELAY:
						node_color = RELAY_NODE_COLOR
						icon_char = "R"
				## Node background tint
				draw_rect(rect, node_color)
				## Node border
				var inset := Rect2(rect.position + Vector2(2, 2), rect.size - Vector2(4, 4))
				draw_rect(inset, Color(node_color, 0.5), false, 1.0)
				## Node icon letter
				var font := ThemeDB.fallback_font
				if font:
					var cx := rect.position.x + CELL_SIZE * 0.5 - 4
					var cy := rect.position.y + CELL_SIZE * 0.5 + 4
					draw_string(font, Vector2(cx, cy), icon_char, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(node_color, 0.8))

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
