## ============================================================================
## ENEMY BASE
## ============================================================================
##
## Purpose: Base class for all enemy types. Handles movement along path,
## HP, damage, status effects (slow/freeze), and death.
##
## @author Signal Lost Team
## @version 0.1.0
class_name EnemyBase
extends Node2D

## Preload scripts to avoid class_name resolution issues
const GridManagerScript = preload("res://scripts/systems/grid_manager.gd")
const ModifierManagerScript = preload("res://scripts/systems/modifier_manager.gd")


## ============================================================================
## SIGNALS
## ============================================================================

signal enemy_died(enemy: Node2D)
signal enemy_reached_core(enemy: Node2D)


## ============================================================================
## EXPORTS
## ============================================================================

@export var enemy_id: String = ""
@export var enemy_name: String = ""
@export var max_hp: float = 30.0
@export var base_speed: float = 120.0
@export var damage_to_core: int = 1
@export var armor: float = 0.0
@export var reward: int = 8
@export var enemy_color: Color = Color.RED


## ============================================================================
## STATE
## ============================================================================

var current_hp: float = 0.0
var _path: PackedVector2Array = PackedVector2Array()
var _path_index: int = 0
var _path_progress: float = 0.0  # 0.0 to 1.0 — how far along the path
var _total_path_length: float = 0.0

## Status effects
var _slow_percent: float = 0.0
var _is_frozen: bool = false
var _freeze_timer: float = 0.0
var _debuff_percent: float = 0.0  # Armor reduction from Scrambler Dish
var _debuff_timer: float = 0.0

## Shield (for Corrupted Signal)
var shield_hp: float = 0.0
var max_shield: float = 0.0

## Elite modifier state
var elite_type: int = 0  ## ModifierManagerScript.EliteType enum value
var encrypted_immunity: bool = false  ## Encrypted: ignore first debuff
var dodge_chance: float = 0.0  ## Ghosted: chance to dodge attacks

## Vulnerability multiplier (Fracture Chill: frozen enemies take more damage)
var _vulnerability_mult: float = 1.0

## Visual
var _hit_flash_timer: float = 0.0
const HIT_FLASH_DURATION := 0.08
var _size_scale: float = 0.6

## Sprite rendering (null = use _draw fallback)
var _sprite: Sprite2D = null
var _use_sprite: bool = false


## ============================================================================
## LIFECYCLE
## ============================================================================

func _physics_process(delta: float) -> void:
	if _path.is_empty() or _path_index >= _path.size():
		return

	## Update freeze
	if _is_frozen:
		_freeze_timer -= delta
		if _freeze_timer <= 0:
			_is_frozen = false
			_vulnerability_mult = 1.0  ## Reset vulnerability when unfreeze
		else:
			queue_redraw()
			return  # Frozen — don't move

	## Update debuff timer
	if _debuff_timer > 0:
		_debuff_timer -= delta
		if _debuff_timer <= 0:
			_debuff_percent = 0.0

	## Movement
	var speed := base_speed * (1.0 - _slow_percent / 100.0)
	var target_pos: Vector2 = _path[_path_index]
	var direction := (target_pos - position).normalized()
	var move_dist := speed * delta
	var dist_to_target := position.distance_to(target_pos)

	if move_dist >= dist_to_target:
		position = target_pos
		_path_index += 1
		if _path_index >= _path.size():
			_reach_core()
			return
	else:
		position += direction * move_dist

	## Update path progress
	if _total_path_length > 0:
		_path_progress = _calculate_progress()

	## Reset slow each frame (must be reapplied by Cryo Node)
	_slow_percent = 0.0

	## Hit flash
	if _hit_flash_timer > 0:
		_hit_flash_timer -= delta

	queue_redraw()


func _draw() -> void:
	_draw_enemy()


## ============================================================================
## PUBLIC API
## ============================================================================

## Initialize enemy for a new spawn.
## wave_mult scales HP fully, speed/armor scale at reduced rates
## to match GDD v2 difficulty curve (HP primary, speed/armor secondary).
func setup(path: PackedVector2Array, wave_mult: float = 1.0) -> void:
	_path = path
	_path_index = 0
	current_hp = max_hp * wave_mult
	## Speed scales at 30% of wave multiplier (prevents late waves being uncatchable)
	var speed_scale := 1.0 + (wave_mult - 1.0) * 0.3
	base_speed = base_speed * speed_scale
	## Armor scales at 50% of wave multiplier
	var armor_scale := 1.0 + (wave_mult - 1.0) * 0.5
	armor = armor * armor_scale
	shield_hp = max_shield * wave_mult
	_slow_percent = 0.0
	_is_frozen = false
	_freeze_timer = 0.0
	_hit_flash_timer = 0.0
	_path_progress = 0.0
	_total_path_length = _calculate_total_path_length()
	if _path.size() > 0:
		position = _path[0]
	add_to_group("enemies")
	_try_load_sprite()


## Apply damage, accounting for armor (reduced by debuff), vulnerability, and shields.
## Returns true if damage was applied, false if dodged (Ghosted elite).
func take_damage(amount: float) -> bool:
	## Ghosted dodge check
	if dodge_chance > 0 and randf() < dodge_chance:
		## Show dodge visual
		_hit_flash_timer = HIT_FLASH_DURATION * 0.5
		queue_redraw()
		return false

	var current_armor := armor * (1.0 - _debuff_percent / 100.0)
	var effective_damage := maxf(amount - current_armor, 1.0)
	## Apply vulnerability (Fracture Chill bonus)
	if _vulnerability_mult > 1.0:
		effective_damage *= _vulnerability_mult

	## Shield absorbs first
	if shield_hp > 0:
		if effective_damage <= shield_hp:
			shield_hp -= effective_damage
			_hit_flash_timer = HIT_FLASH_DURATION
			queue_redraw()
			return true
		else:
			effective_damage -= shield_hp
			shield_hp = 0

	current_hp -= effective_damage
	_hit_flash_timer = HIT_FLASH_DURATION

	if current_hp <= 0:
		_die()
	return true


## Apply slow effect (percentage, 0-100).
func apply_slow(percent: float) -> void:
	_slow_percent = maxf(_slow_percent, percent)  # Take strongest slow


## Apply freeze effect with optional vulnerability bonus (Fracture Chill).
func apply_freeze(duration: float, vulnerability: float = 1.0) -> void:
	_is_frozen = true
	_freeze_timer = duration
	if vulnerability > 1.0:
		_vulnerability_mult = maxf(_vulnerability_mult, vulnerability)


## Apply armor/resistance debuff from Scrambler Dish.
func apply_debuff(percent: float, duration: float) -> void:
	## Encrypted elite: immune to first debuff application
	if encrypted_immunity:
		encrypted_immunity = false
		return
	_debuff_percent = maxf(_debuff_percent, percent)
	_debuff_timer = maxf(_debuff_timer, duration)


## Check if currently frozen.
func is_frozen() -> bool:
	return _is_frozen


## Get current HP.
func get_current_hp() -> float:
	return current_hp


## Get path progress (0.0 = spawn, 1.0 = core).
func get_path_progress() -> float:
	return _path_progress


## Pool callbacks.
func on_pool_acquire() -> void:
	_path.clear()
	_path_index = 0
	current_hp = max_hp
	shield_hp = max_shield
	_slow_percent = 0.0
	_is_frozen = false
	elite_type = 0
	encrypted_immunity = false
	dodge_chance = 0.0


func on_pool_release() -> void:
	remove_from_group("enemies")


## ============================================================================
## PRIVATE
## ============================================================================

func _die() -> void:
	GameManager.add_scrap(reward)
	GameManager.add_signal_charge(GameManager.CHARGE_PER_KILL)
	RunManager.enemies_killed += 1
	RunManager.scrap_earned += reward
	enemy_died.emit(self)


func _reach_core() -> void:
	GameManager.damage_core(damage_to_core)
	enemy_reached_core.emit(self)


func _calculate_total_path_length() -> float:
	var total := 0.0
	for i in range(1, _path.size()):
		total += _path[i - 1].distance_to(_path[i])
	return total


func _calculate_progress() -> float:
	if _total_path_length <= 0:
		return 0.0
	var dist_traveled := 0.0
	for i in range(1, _path_index + 1):
		if i < _path.size():
			dist_traveled += _path[i - 1].distance_to(_path[i])
	## Add partial distance to current target
	if _path_index < _path.size() and _path_index > 0:
		dist_traveled += _path[_path_index - 1].distance_to(position)
	return clampf(dist_traveled / _total_path_length, 0.0, 1.0)


## ============================================================================
## DRAWING
## ============================================================================

func _draw_enemy() -> void:
	var size := GridManagerScript.CELL_SIZE * _size_scale * 0.4

	if _use_sprite:
		## Sprite mode: apply visual effects to sprite, draw HP/shield bars only
		if _hit_flash_timer > 0:
			_sprite.modulate = Color.WHITE
		elif _is_frozen:
			_sprite.modulate = Color(0.53, 0.87, 1)
			for i in 4:
				var angle := deg_to_rad(90 * i + 45)
				var p := Vector2(cos(angle), sin(angle)) * size * 1.3
				draw_line(Vector2.ZERO, p, Color(0.53, 0.87, 1, 0.6), 1.0)
		else:
			_sprite.modulate = Color.WHITE
		_draw_hp_bar(size)
		if max_shield > 0:
			_draw_shield_bar(size)
		return

	## Placeholder fallback — diamond shape
	var color := enemy_color

	## Hit flash — white
	if _hit_flash_timer > 0:
		color = Color.WHITE

	## Freeze tint
	if _is_frozen:
		color = Color(0.53, 0.87, 1)
		## Ice crystal effect
		for i in 4:
			var angle := deg_to_rad(90 * i + 45)
			var p := Vector2(cos(angle), sin(angle)) * size * 1.3
			draw_line(Vector2.ZERO, p, Color(0.53, 0.87, 1, 0.6), 1.0)

	## Enemy body (diamond shape)
	var points := PackedVector2Array([
		Vector2(0, -size),
		Vector2(size, 0),
		Vector2(0, size),
		Vector2(-size, 0)
	])
	draw_colored_polygon(points, Color(color, 0.8))
	draw_polyline(points + PackedVector2Array([points[0]]), color, 1.5)

	## HP bar
	_draw_hp_bar(size)

	## Shield bar (if has shield)
	if max_shield > 0:
		_draw_shield_bar(size)

	## Elite indicator
	if elite_type != 0:
		_draw_elite_indicator(size)


func _draw_elite_indicator(size: float) -> void:
	var elite_color := ModifierManagerScript.get_elite_color(elite_type)
	## Pulsing glow ring around elite enemies
	var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.005)
	var ring_alpha := 0.3 + pulse * 0.3
	draw_arc(Vector2.ZERO, size * 1.5, 0, TAU, 16, Color(elite_color, ring_alpha), 1.5)
	## Elite type icon at top-right
	var icon_pos := Vector2(size * 0.8, -size - 14)
	var icon_char := ""
	match elite_type:
		1: icon_char = "E"  ## Encrypted
		2: icon_char = "O"  ## Overclocked
		3: icon_char = "G"  ## Ghosted
	var font := ThemeDB.fallback_font
	if font and icon_char != "":
		draw_string(font, icon_pos, icon_char, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, elite_color)


func _draw_hp_bar(size: float) -> void:
	var bar_width := size * 2.0
	var bar_height := 3.0
	var bar_y := -size - 8.0
	var hp_ratio := clampf(current_hp / max_hp, 0.0, 1.0)

	## Background
	draw_rect(Rect2(-bar_width * 0.5, bar_y, bar_width, bar_height), Color(0.2, 0.2, 0.2, 0.7))
	## HP fill
	var hp_color := Color.GREEN if hp_ratio > 0.5 else (Color.YELLOW if hp_ratio > 0.25 else Color.RED)
	draw_rect(Rect2(-bar_width * 0.5, bar_y, bar_width * hp_ratio, bar_height), hp_color)


func _draw_shield_bar(size: float) -> void:
	if max_shield <= 0:
		return
	var bar_width := size * 2.0
	var bar_height := 2.0
	var bar_y := -size - 12.0
	var shield_ratio := clampf(shield_hp / max_shield, 0.0, 1.0)

	draw_rect(Rect2(-bar_width * 0.5, bar_y, bar_width * shield_ratio, bar_height), Color(0.3, 0.5, 1, 0.8))


## Try to load a sprite texture for this enemy. If found, creates a
## Sprite2D child and sets _use_sprite = true so _draw_enemy() skips
## the placeholder geometry.
func _try_load_sprite() -> void:
	var path := "res://assets/sprites/enemies/%s.png" % enemy_id
	if not ResourceLoader.exists(path):
		return

	var texture: Texture2D = load(path) as Texture2D
	if not texture:
		return

	_sprite = Sprite2D.new()
	_sprite.texture = texture
	add_child(_sprite)
	_use_sprite = true
