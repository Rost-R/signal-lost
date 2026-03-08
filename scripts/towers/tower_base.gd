## ============================================================================
## TOWER BASE
## ============================================================================
##
## Purpose: Base class for all tower types. Handles targeting, attack timing,
## synergy bonuses, upgrades, and visual state.
## Subclasses override _attack() to implement specific behavior.
##
## @author Signal Lost Team
## @version 0.1.0
class_name TowerBase
extends Node2D

## Preload scripts to avoid class_name resolution issues
const GridManagerScript = preload("res://scripts/systems/grid_manager.gd")


## ============================================================================
## SIGNALS
## ============================================================================

signal tower_upgraded(new_level: int)
signal tower_sold()
signal attack_fired(target: Node2D)
signal branch_choice_needed(tower: Node2D, branches: Array)


## ============================================================================
## EXPORTS
## ============================================================================

@export var tower_id: String = ""
@export var tower_name: String = ""
@export var base_damage: float = 0.0
@export var base_attack_speed: float = 1.0
@export var base_range: float = 3.0
@export var base_cost: int = 50
@export var power_cost: int = 1
@export var sell_refund_percent: float = 0.7
@export var tower_color: Color = Color.CYAN


## ============================================================================
## STATE
## ============================================================================

var level: int = 1
var grid_position: Vector2i = Vector2i.ZERO
var upgrade_branch: String = ""  ## "" = no branch chosen, "a" or "b"

## Synergy-modified stats (recalculated when neighbors change).
var effective_damage: float = 0.0
var effective_attack_speed: float = 0.0
var effective_range: float = 0.0

## Targeting
var current_target: Node2D = null
var target_priority: GameManager.TargetPriority = GameManager.TargetPriority.FIRST
var _attack_timer: float = 0.0

## Synergy state
var _synergy_damage_mult: float = 1.0
var _synergy_speed_mult: float = 1.0
var _synergy_range_mult: float = 1.0

## Sprite rendering (null = use _draw fallback)
var _sprite: Sprite2D = null
var _use_sprite: bool = false

## Visual
var _range_visible: bool = false


## ============================================================================
## LIFECYCLE
## ============================================================================

func _ready() -> void:
	recalculate_stats()
	_try_load_sprite()


func _physics_process(delta: float) -> void:
	if not GameManager.is_running:
		return
	if GameManager.current_phase != GameManager.GamePhase.WAVE and \
	   GameManager.current_phase != GameManager.GamePhase.BOSS:
		return

	_attack_timer += delta
	_update_target()

	if current_target and _attack_timer >= (1.0 / effective_attack_speed):
		_attack_timer = 0.0
		_attack(current_target)
		attack_fired.emit(current_target)
		GameManager.add_signal_charge(GameManager.CHARGE_PER_ATTACK)

	queue_redraw()


func _draw() -> void:
	_draw_tower()
	if _range_visible:
		_draw_range()


## ============================================================================
## PUBLIC API
## ============================================================================

func get_tower_id() -> String:
	return tower_id


## Recalculate effective stats based on level + synergy bonuses.
func recalculate_stats() -> void:
	var level_data := _get_level_stats()
	effective_damage = level_data.damage * _synergy_damage_mult
	effective_attack_speed = level_data.attack_speed * _synergy_speed_mult
	effective_range = level_data.range * _synergy_range_mult


## Apply synergy multipliers (called by synergy calculator).
func apply_synergy(damage_mult: float, speed_mult: float, range_mult: float) -> void:
	_synergy_damage_mult = clampf(damage_mult, 1.0, 3.0)  # Cap at 200% bonus
	_synergy_speed_mult = clampf(speed_mult, 1.0, 3.0)
	_synergy_range_mult = clampf(range_mult, 1.0, 3.0)
	recalculate_stats()


## Get total scrap invested in this tower (base + all upgrade costs).
func get_total_invested() -> int:
	var total := base_cost
	if level >= 2:
		if upgrade_branch != "":
			total += _get_branch_upgrade_cost(upgrade_branch, 2)
		else:
			total += _get_upgrade_cost(2)
	if level >= 3:
		if upgrade_branch != "":
			total += _get_branch_upgrade_cost(upgrade_branch, 3)
		else:
			total += _get_upgrade_cost(3)
	return total


## Get sell value based on total investment.
func get_sell_value() -> int:
	return int(get_total_invested() * sell_refund_percent)


## Upgrade the tower to the next level. Returns false if max level or can't afford.
## If the tower has branches and is level 1, emits branch_choice_needed instead.
func upgrade() -> bool:
	if level >= 3:
		return false
	## Level 1→2: check if branches exist
	if level == 1 and _has_branches():
		var branches := _get_branch_info()
		branch_choice_needed.emit(self, branches)
		return false  ## Don't upgrade yet — wait for branch choice
	var cost := _get_upgrade_cost(level + 1)
	if not GameManager.spend_scrap(cost):
		return false
	level += 1
	recalculate_stats()
	_refresh_sprite()
	tower_upgraded.emit(level)
	return true


## Upgrade with a specific branch choice (called when player picks a branch).
func upgrade_with_branch(branch_id: String) -> bool:
	if level != 1 or not _has_branches():
		return false
	var cost := _get_branch_upgrade_cost(branch_id, 2)
	if not GameManager.spend_scrap(cost):
		return false
	upgrade_branch = branch_id
	level = 2
	recalculate_stats()
	_refresh_sprite()
	tower_upgraded.emit(level)
	return true


## Get upgrade cost for a specific level.
func get_next_upgrade_cost() -> int:
	if level >= 3:
		return -1
	if level == 1 and _has_branches():
		## Return cost of branch A as preview (both branches cost the same)
		return _get_branch_upgrade_cost("a", 2)
	return _get_upgrade_cost(level + 1)


## Get the name of the chosen branch (empty if no branch).
func get_branch_name() -> String:
	if upgrade_branch == "":
		return ""
	var branches := _get_branch_info()
	for b in branches:
		if b.id == upgrade_branch:
			return b.name
	return ""


## Show/hide range indicator.
func set_range_visible(visible: bool) -> void:
	_range_visible = visible
	queue_redraw()


## Called when acquired from object pool.
func on_pool_acquire() -> void:
	level = 1
	upgrade_branch = ""
	_synergy_damage_mult = 1.0
	_synergy_speed_mult = 1.0
	_synergy_range_mult = 1.0
	_attack_timer = 0.0
	current_target = null
	recalculate_stats()


## Called when released back to object pool.
func on_pool_release() -> void:
	current_target = null


## ============================================================================
## TARGETING
## ============================================================================

func _update_target() -> void:
	var enemies := _get_enemies_in_range()
	if enemies.is_empty():
		current_target = null
		return

	match target_priority:
		GameManager.TargetPriority.FIRST:
			current_target = _get_first_enemy(enemies)
		GameManager.TargetPriority.LAST:
			current_target = _get_last_enemy(enemies)
		GameManager.TargetPriority.STRONGEST:
			current_target = _get_strongest_enemy(enemies)
		GameManager.TargetPriority.WEAKEST:
			current_target = _get_weakest_enemy(enemies)


func _get_enemies_in_range() -> Array[Node2D]:
	var result: Array[Node2D] = []
	var range_px := effective_range * GridManagerScript.CELL_SIZE
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.visible:
			if position.distance_to(enemy.position) <= range_px:
				result.append(enemy)
	return result


func _get_first_enemy(enemies: Array[Node2D]) -> Node2D:
	## "First" = closest to the core (most progress along path).
	var best: Node2D = null
	var best_progress: float = -1.0
	for enemy in enemies:
		if enemy.has_method("get_path_progress"):
			var prog: float = enemy.get_path_progress()
			if prog > best_progress:
				best_progress = prog
				best = enemy
	return best if best else enemies[0]


func _get_last_enemy(enemies: Array[Node2D]) -> Node2D:
	var best: Node2D = null
	var best_progress: float = INF
	for enemy in enemies:
		if enemy.has_method("get_path_progress"):
			var prog: float = enemy.get_path_progress()
			if prog < best_progress:
				best_progress = prog
				best = enemy
	return best if best else enemies[0]


func _get_strongest_enemy(enemies: Array[Node2D]) -> Node2D:
	var best: Node2D = null
	var best_hp: float = -1.0
	for enemy in enemies:
		if enemy.has_method("get_current_hp"):
			var hp: float = enemy.get_current_hp()
			if hp > best_hp:
				best_hp = hp
				best = enemy
	return best if best else enemies[0]


func _get_weakest_enemy(enemies: Array[Node2D]) -> Node2D:
	var best: Node2D = null
	var best_hp: float = INF
	for enemy in enemies:
		if enemy.has_method("get_current_hp"):
			var hp: float = enemy.get_current_hp()
			if hp < best_hp:
				best_hp = hp
				best = enemy
	return best if best else enemies[0]


## ============================================================================
## VIRTUAL METHODS (Override in subclasses)
## ============================================================================

## Execute attack on target. Override in subclass.
func _attack(_target: Node2D) -> void:
	pass


## Get stats for current level. Override if tower has special stats.
func _get_level_stats() -> Dictionary:
	return {
		"damage": base_damage,
		"attack_speed": base_attack_speed,
		"range": base_range
	}


## Get upgrade cost for a level (linear path, no branches).
func _get_upgrade_cost(_target_level: int) -> int:
	return base_cost  # Override per tower


## Whether this tower has upgrade branches. Override to return true.
func _has_branches() -> bool:
	return false


## Get branch info for the UI. Override per tower.
## Returns: [{ id: "a", name: "Branch Name", description: "...", cost: 80 }, ...]
func _get_branch_info() -> Array:
	return []


## Get upgrade cost for a specific branch and level. Override per tower.
func _get_branch_upgrade_cost(_branch_id: String, _target_level: int) -> int:
	return base_cost


## ============================================================================
## DRAWING
## ============================================================================

func _draw_tower() -> void:
	## If using sprite, only draw level indicator dots
	if _use_sprite:
		var size := GridManagerScript.CELL_SIZE * 0.35
		for i in level:
			var dot_x := (i - (level - 1) * 0.5) * 6.0
			draw_circle(Vector2(dot_x, size + 6), 2.0, tower_color)
		return

	## Base — hexagonal shape (placeholder fallback)
	var size := GridManagerScript.CELL_SIZE * 0.35
	var points := PackedVector2Array()
	for i in 6:
		var angle := deg_to_rad(60 * i - 30)
		points.append(Vector2(cos(angle), sin(angle)) * size)
	draw_colored_polygon(points, tower_color * Color(1, 1, 1, 0.8))
	draw_polyline(points + PackedVector2Array([points[0]]), tower_color, 2.0)

	## Level indicator dots
	for i in level:
		var dot_x := (i - (level - 1) * 0.5) * 6.0
		draw_circle(Vector2(dot_x, size + 6), 2.0, tower_color)


func _draw_range() -> void:
	var range_px := effective_range * GridManagerScript.CELL_SIZE
	draw_arc(Vector2.ZERO, range_px, 0, TAU, 64, Color(tower_color, 0.15), 1.0)


## Try to load a sprite texture for this tower. If found, creates a
## Sprite2D child and sets _use_sprite = true so _draw_tower() skips
## the placeholder geometry.
func _try_load_sprite() -> void:
	var path: String
	if upgrade_branch != "" and level >= 2:
		path = "res://assets/sprites/towers/%s_lv%d_%s.png" % [tower_id, level, upgrade_branch]
	else:
		path = "res://assets/sprites/towers/%s_lv%d.png" % [tower_id, level]

	if not ResourceLoader.exists(path):
		return

	var texture: Texture2D = load(path) as Texture2D
	if not texture:
		return

	if _sprite:
		_sprite.texture = texture
	else:
		_sprite = Sprite2D.new()
		_sprite.texture = texture
		add_child(_sprite)
	_use_sprite = true


## Call after upgrade to refresh sprite for new level/branch.
func _refresh_sprite() -> void:
	_try_load_sprite()
