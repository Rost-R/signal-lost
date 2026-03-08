## ============================================================================
## SHIELD GENERATOR
## ============================================================================
##
## Purpose: Defensive tower that projects a shield absorbing damage to the
## relay core. When enemies reach the core, shield HP is consumed first.
## Synergy: Recharges 50% faster when adjacent to Cryo Node.
##
## @author Signal Lost Team
## @version 0.1.0
class_name ShieldGenerator
extends "res://scripts/towers/tower_base.gd"

## GridManagerScript inherited from TowerBase via preload()


## ============================================================================
## CONSTANTS
## ============================================================================

const UPGRADE_DATA := [
	{},
	{ "shield_hp": 80, "recharge_rate": 3.0, "recharge_delay": 4.0, "cost": 150 },
	{ "shield_hp": 120, "recharge_rate": 5.0, "recharge_delay": 3.0, "cost": 300 },
]


## ============================================================================
## STATE
## ============================================================================

var base_shield_hp: int = 50
var base_recharge_rate: float = 2.0  # HP per second
var base_recharge_delay: float = 5.0  # Seconds after last damage before recharging

var current_shield: float = 0.0
var max_shield_hp: int = 50
var _recharge_cooldown: float = 0.0
var _cryo_adjacent: bool = false  # Synergy flag


## ============================================================================
## LIFECYCLE
## ============================================================================

func _init() -> void:
	tower_id = "shield_generator"
	tower_name = "Shield Gen"
	base_damage = 0.0
	base_attack_speed = 0.0
	base_range = 2.0
	base_cost = 250
	tower_color = Color(0.67, 0.27, 1)  # #AA44FF


func _ready() -> void:
	super._ready()
	max_shield_hp = _get_effective_shield_hp()
	current_shield = max_shield_hp


func _physics_process(delta: float) -> void:
	if not GameManager.is_running:
		return

	## Recharge shield
	if _recharge_cooldown > 0:
		_recharge_cooldown -= delta
	elif current_shield < max_shield_hp:
		var rate := _get_effective_recharge_rate()
		if _cryo_adjacent:
			rate *= 1.5  # Cryo Node synergy
		current_shield = minf(current_shield + rate * delta, max_shield_hp)

	queue_redraw()


## ============================================================================
## SHIELD LOGIC
## ============================================================================

## Absorb damage that would hit the core. Returns remaining damage not absorbed.
func absorb_damage(damage: int) -> int:
	if current_shield <= 0:
		return damage

	var absorbed := mini(damage, int(current_shield))
	current_shield -= absorbed
	_recharge_cooldown = _get_effective_recharge_delay()
	return damage - absorbed


## Set cryo adjacency flag (called by synergy system).
func set_cryo_adjacent(adjacent: bool) -> void:
	_cryo_adjacent = adjacent


## ============================================================================
## STATS
## ============================================================================

func _get_effective_shield_hp() -> int:
	if level <= 1:
		return base_shield_hp
	return UPGRADE_DATA[level - 1].get("shield_hp", base_shield_hp)


func _get_effective_recharge_rate() -> float:
	if level <= 1:
		return base_recharge_rate
	return UPGRADE_DATA[level - 1].get("recharge_rate", base_recharge_rate)


func _get_effective_recharge_delay() -> float:
	if level <= 1:
		return base_recharge_delay
	return UPGRADE_DATA[level - 1].get("recharge_delay", base_recharge_delay)


func _get_level_stats() -> Dictionary:
	return {
		"damage": 0.0,
		"attack_speed": 0.0,
		"range": base_range
	}


func _get_upgrade_cost(target_level: int) -> int:
	if target_level <= 1 or target_level > UPGRADE_DATA.size():
		return base_cost
	return UPGRADE_DATA[target_level - 1].get("cost", base_cost)


## Override upgrade to update shield HP.
func upgrade() -> bool:
	var result := super.upgrade()
	if result:
		max_shield_hp = _get_effective_shield_hp()
		current_shield = max_shield_hp  # Full recharge on upgrade
	return result


## ============================================================================
## DRAWING
## ============================================================================

func _draw() -> void:
	super._draw()

	## Draw shield bubble
	var shield_ratio := current_shield / max_shield_hp if max_shield_hp > 0 else 0.0
	var radius := GridManagerScript.CELL_SIZE * 0.45
	var alpha := 0.1 + shield_ratio * 0.3

	## Shield arc (shows remaining shield as partial circle)
	var arc_end := TAU * shield_ratio
	if arc_end > 0:
		draw_arc(Vector2.ZERO, radius, -PI * 0.5, -PI * 0.5 + arc_end, 48, Color(0.67, 0.27, 1, alpha), 2.0)

	## Full circle outline (dimmed)
	draw_arc(Vector2.ZERO, radius, 0, TAU, 48, Color(0.67, 0.27, 1, 0.08), 1.0)

	## Shield HP text
	var font := ThemeDB.fallback_font
	if font:
		var shield_text := "%d" % int(current_shield)
		var text_size := font.get_string_size(shield_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 10)
		draw_string(font, Vector2(-text_size.x * 0.5, radius + 14), shield_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(0.67, 0.27, 1, 0.7))

	## Cryo synergy indicator
	if _cryo_adjacent:
		var pulse: float = abs(sin(Time.get_ticks_msec() * 0.003))
		draw_arc(Vector2.ZERO, radius + 4, 0, TAU, 32, Color(0.53, 0.87, 1, pulse * 0.2), 1.0)
