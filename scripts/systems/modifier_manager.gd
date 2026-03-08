## ============================================================================
## MODIFIER MANAGER
## ============================================================================
##
## Purpose: Manages run modifiers — selection, application, and runtime
## queries. Loads modifier definitions from data/modifiers.json.
## Also handles elite enemy modifiers (Encrypted, Overclocked, Ghosted).
##
## @author Signal Lost Team
## @version 0.1.0
class_name ModifierManager
extends Node


## ============================================================================
## SIGNALS
## ============================================================================

signal modifier_selected(modifier_id: String)


## ============================================================================
## CONSTANTS — Elite Modifier Definitions
## ============================================================================

## Elite modifier types applied to individual enemies at spawn time.
enum EliteType { NONE, ENCRYPTED, OVERCLOCKED, GHOSTED }

## Base chance for an enemy to become elite (scales with wave number).
const BASE_ELITE_CHANCE := 0.0
const ELITE_CHANCE_PER_WAVE := 0.04  ## +4% per wave → wave 5 = 20%, wave 10 = 40%

## Elite stat multipliers
const ELITE_HP_MULT := 2.0
const ELITE_REWARD_MULT := 2.0

## Encrypted: +50% armor, immune to first debuff application
const ENCRYPTED_ARMOR_MULT := 1.5
## Overclocked: +60% speed
const OVERCLOCKED_SPEED_MULT := 1.6
## Ghosted: 40% chance to dodge attacks
const GHOSTED_DODGE_CHANCE := 0.40


## ============================================================================
## STATE
## ============================================================================

## All modifier definitions loaded from JSON.
var _modifier_data: Dictionary = {}

## Currently active run modifier (empty = none selected).
var active_modifier_id: String = ""
var active_modifier: Dictionary = {}

## Cached effect values for fast runtime lookups.
var _effects: Dictionary = {}


## ============================================================================
## LIFECYCLE
## ============================================================================

func _ready() -> void:
	_load_modifier_data()


## ============================================================================
## PUBLIC API — Run Modifiers
## ============================================================================

## Reset state for a new run.
func reset() -> void:
	active_modifier_id = ""
	active_modifier = {}
	_effects = {}


## Generate 3 random modifier choices (weighted by rarity).
func generate_choices() -> Array[Dictionary]:
	var all_ids: Array[String] = []
	for key in _modifier_data.keys():
		all_ids.append(key)

	## Shuffle and pick 3 (ensure different rarities when possible)
	all_ids.shuffle()
	var choices: Array[Dictionary] = []
	var used_ids: Array[String] = []

	## Try to get one from each rarity tier first
	for rarity in ["common", "uncommon", "rare"]:
		for mid in all_ids:
			if mid in used_ids:
				continue
			var mod: Dictionary = _modifier_data.get(mid, {})
			if mod.get("rarity", "") == rarity:
				choices.append(_build_choice(mid, mod))
				used_ids.append(mid)
				break

	## If we have fewer than 3 (unlikely), fill from remaining
	while choices.size() < 3 and used_ids.size() < all_ids.size():
		for mid in all_ids:
			if mid not in used_ids:
				choices.append(_build_choice(mid, _modifier_data[mid]))
				used_ids.append(mid)
				break

	return choices


## Apply a selected modifier by ID. Called after player picks from the UI.
func select_modifier(modifier_id: String) -> void:
	if modifier_id == "":
		return
	active_modifier_id = modifier_id
	active_modifier = _modifier_data.get(modifier_id, {})
	_effects = active_modifier.get("effects", {})

	## Register with RunManager
	RunManager.apply_modifier(modifier_id)
	modifier_selected.emit(modifier_id)

	## Apply immediate effects to GameManager
	_apply_immediate_effects()


## Get an effect value. Returns default if not present.
func get_effect(effect_key: String, default_value: Variant = 0.0) -> Variant:
	return _effects.get(effect_key, default_value)


## Check if a specific effect is active.
func has_effect(effect_key: String) -> bool:
	return _effects.has(effect_key)


## Get the display name of the active modifier (for HUD).
func get_active_modifier_name() -> String:
	return active_modifier.get("name", "")


## ============================================================================
## PUBLIC API — Elite Enemy Modifiers
## ============================================================================

## Determine if a spawned enemy should become elite and which type.
## Returns EliteType enum value.
func roll_elite_type(wave_number: int) -> EliteType:
	var extra_elites: int = int(get_effect("extra_elite_per_wave", 0))
	var chance: float = BASE_ELITE_CHANCE + ELITE_CHANCE_PER_WAVE * wave_number

	## Waves 1-2: no elites unless modifier forces them
	if wave_number <= 2 and extra_elites <= 0:
		return EliteType.NONE

	if randf() < chance or extra_elites > 0:
		## Pick random elite type
		var roll := randi() % 3
		match roll:
			0: return EliteType.ENCRYPTED
			1: return EliteType.OVERCLOCKED
			2: return EliteType.GHOSTED

	return EliteType.NONE


## Apply elite modifier stats to an enemy. Called after enemy.setup().
func apply_elite_to_enemy(enemy: Node2D, elite_type: EliteType) -> void:
	if elite_type == EliteType.NONE:
		return

	## Set the elite type on the enemy
	if "elite_type" in enemy:
		enemy.elite_type = elite_type

	## Universal elite buffs: 2x HP, 2x reward
	enemy.current_hp *= ELITE_HP_MULT
	enemy.max_hp *= ELITE_HP_MULT
	enemy.reward = int(enemy.reward * ELITE_REWARD_MULT)

	## Type-specific buffs
	match elite_type:
		EliteType.ENCRYPTED:
			enemy.armor *= ENCRYPTED_ARMOR_MULT
			if "encrypted_immunity" in enemy:
				enemy.encrypted_immunity = true
		EliteType.OVERCLOCKED:
			enemy.base_speed *= OVERCLOCKED_SPEED_MULT
		EliteType.GHOSTED:
			if "dodge_chance" in enemy:
				enemy.dodge_chance = GHOSTED_DODGE_CHANCE


## Get elite type display name.
static func get_elite_name(elite_type: EliteType) -> String:
	match elite_type:
		EliteType.ENCRYPTED: return "Encrypted"
		EliteType.OVERCLOCKED: return "Overclocked"
		EliteType.GHOSTED: return "Ghosted"
		_: return ""


## Get elite type display color.
static func get_elite_color(elite_type: EliteType) -> Color:
	match elite_type:
		EliteType.ENCRYPTED: return Color(0.3, 0.5, 1)      # Blue
		EliteType.OVERCLOCKED: return Color(1, 0.4, 0.1)    # Orange
		EliteType.GHOSTED: return Color(0.6, 0.2, 0.8)      # Purple
		_: return Color.WHITE


## ============================================================================
## PUBLIC API — Run Modifier Effects on Enemies
## ============================================================================

## Apply run modifier effects to an enemy at spawn time.
func apply_run_effects_to_enemy(enemy: Node2D) -> void:
	## Enemy HP multiplier
	var hp_mult: float = get_effect("enemy_hp_multiply", 1.0)
	if hp_mult != 1.0:
		enemy.current_hp *= hp_mult
		enemy.max_hp *= hp_mult

	## Enemy speed multiplier
	var speed_mult: float = get_effect("enemy_speed_multiply", 1.0)
	if speed_mult != 1.0:
		enemy.base_speed *= speed_mult

	## Enemy reward multiplier
	var reward_mult: float = get_effect("enemy_reward_multiply", 1.0)
	if reward_mult != 1.0:
		enemy.reward = int(enemy.reward * reward_mult)


## ============================================================================
## PRIVATE
## ============================================================================

## Apply effects that modify GameManager state immediately on selection.
func _apply_immediate_effects() -> void:
	## Core HP modifications
	var core_hp_mult: float = get_effect("core_hp_multiply", 1.0)
	if core_hp_mult != 1.0:
		GameManager.core_hp = int(GameManager.core_hp * core_hp_mult)

	var core_hp_add: int = int(get_effect("core_hp_add", 0))
	if core_hp_add != 0:
		GameManager.core_hp += core_hp_add

	var core_hp_override: int = int(get_effect("core_hp_override", 0))
	if core_hp_override > 0:
		GameManager.core_hp = core_hp_override

	## Starting resources multiplier
	var res_mult: float = get_effect("starting_resources_multiply", 1.0)
	if res_mult != 1.0:
		GameManager.scrap = int(GameManager.scrap * res_mult)


func _build_choice(modifier_id: String, mod: Dictionary) -> Dictionary:
	return {
		"id": modifier_id,
		"name": mod.get("name", modifier_id),
		"description": mod.get("description", ""),
		"icon": mod.get("icon", ""),
		"rarity": mod.get("rarity", "common"),
		"effects": mod.get("effects", {}),
	}


func _load_modifier_data() -> void:
	var file := FileAccess.open("res://data/modifiers.json", FileAccess.READ)
	if not file:
		push_warning("ModifierManager: modifiers.json not found")
		return
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_warning("ModifierManager: Failed to parse modifiers.json")
		return
	_modifier_data = json.data.get("modifiers", {})
