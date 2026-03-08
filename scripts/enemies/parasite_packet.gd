## ============================================================================
## PARASITE PACKET
## ============================================================================
##
## Purpose: Support enemy that heals or buffs nearby allies. Priority target.
## Heals all enemies within a small radius every few seconds.
##
## @author Signal Lost Team
## @version 0.1.0
class_name ParasitePacket
extends "res://scripts/enemies/enemy_base.gd"

## GridManagerScript inherited from EnemyBase via preload()


## ============================================================================
## CONSTANTS
## ============================================================================

const HEAL_RANGE_PX := 96.0    # ~1.5 cells
const HEAL_AMOUNT := 8.0       # HP healed per tick
const HEAL_INTERVAL := 2.0     # Seconds between heals
const HEAL_FLASH_DURATION := 0.15


## ============================================================================
## STATE
## ============================================================================

var _heal_timer: float = HEAL_INTERVAL
var _heal_flash_timer: float = 0.0


## ============================================================================
## LIFECYCLE
## ============================================================================

func _init() -> void:
	enemy_id = "parasite_packet"
	enemy_name = "Parasite Packet"
	max_hp = 45.0
	base_speed = 75.0
	damage_to_core = 1
	armor = 0.0
	reward = 20
	enemy_color = Color(0.6, 1, 0.2)  # #99FF33 — sickly green
	_size_scale = 0.55


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	## Heal nearby allies
	if not _is_frozen and visible:
		_heal_timer -= delta
		if _heal_timer <= 0:
			_heal_nearby()
			_heal_timer = HEAL_INTERVAL

	if _heal_flash_timer > 0:
		_heal_flash_timer -= delta
		queue_redraw()


## ============================================================================
## HEALING
## ============================================================================

func _heal_nearby() -> void:
	var enemies := get_tree().get_nodes_in_group("enemies")
	var healed_any := false
	for enemy in enemies:
		if enemy == self or not is_instance_valid(enemy) or not enemy.visible:
			continue
		var dist := global_position.distance_to(enemy.global_position)
		if dist <= HEAL_RANGE_PX:
			if enemy.has_method("receive_heal"):
				enemy.receive_heal(HEAL_AMOUNT)
				healed_any = true
			elif "current_hp" in enemy and "max_hp" in enemy:
				enemy.current_hp = minf(enemy.current_hp + HEAL_AMOUNT, enemy.max_hp)
				healed_any = true

	if healed_any:
		_heal_flash_timer = HEAL_FLASH_DURATION


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

	## Cross/plus shape — medical/support
	var arm := size * 0.35
	var points := PackedVector2Array([
		Vector2(-arm, -size),
		Vector2(arm, -size),
		Vector2(arm, -arm),
		Vector2(size, -arm),
		Vector2(size, arm),
		Vector2(arm, arm),
		Vector2(arm, size),
		Vector2(-arm, size),
		Vector2(-arm, arm),
		Vector2(-size, arm),
		Vector2(-size, -arm),
		Vector2(-arm, -arm),
	])
	draw_colored_polygon(points, Color(color, 0.6))
	draw_polyline(points + PackedVector2Array([points[0]]), color, 1.5)

	## Heal pulse effect
	if _heal_flash_timer > 0:
		var alpha := _heal_flash_timer / HEAL_FLASH_DURATION
		draw_arc(Vector2.ZERO, HEAL_RANGE_PX * 0.3, 0, TAU, 24, Color(0.6, 1, 0.2, alpha * 0.3), 1.5)

	_draw_hp_bar(size)
