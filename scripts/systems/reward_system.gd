## ============================================================================
## REWARD SYSTEM
## ============================================================================
##
## Purpose: Generates between-wave reward choices from the reward pool.
## Player picks 1 of 3 rewards after clearing each wave (except boss wave).
## Reward effects are applied immediately via GameManager/RunManager.
##
## @author Signal Lost Team
## @version 0.3.0
extends Node


## ============================================================================
## SIGNALS
## ============================================================================

signal rewards_generated(choices: Array)
signal reward_applied(reward: Dictionary)


## ============================================================================
## STATE
## ============================================================================

var _reward_pool: Array = []
var _current_choices: Array = []

## Run-wide passive bonuses accumulated from reward choices
var run_damage_bonus: float = 0.0
var run_speed_bonus: float = 0.0
var run_range_bonus: float = 0.0
var run_cost_reduction: float = 0.0
var run_sell_refund: float = 0.70  # Default 70%


## ============================================================================
## LIFECYCLE
## ============================================================================

func _ready() -> void:
	_load_reward_pool()


## ============================================================================
## PUBLIC API
## ============================================================================

## Generate 3 unique reward choices for the current wave.
## If the wave was flawless (no core damage taken), include the flawless bonus.
func generate_choices(wave_number: int, was_flawless: bool = false) -> Array:
	var eligible: Array = []

	for reward in _reward_pool:
		if reward.get("weight", 0) <= 0 and reward["id"] != "flawless_scrap":
			continue
		if wave_number < reward.get("min_wave", 1):
			continue
		eligible.append(reward)

	## Add flawless bonus to pool if wave was flawless
	if was_flawless:
		for reward in _reward_pool:
			if reward["id"] == "flawless_scrap" and reward not in eligible:
				eligible.append(reward)

	## Weighted random selection of 3 unique rewards
	_current_choices = _weighted_pick(eligible, 3, wave_number)
	rewards_generated.emit(_current_choices)
	return _current_choices


## Apply the chosen reward. Called when player selects one of the 3 choices.
func apply_reward(reward: Dictionary) -> void:
	var effect: Dictionary = reward.get("effect", {})

	## Immediate effects
	if effect.has("scrap"):
		GameManager.add_scrap(int(effect["scrap"]))

	if effect.has("heal"):
		var heal_amount: int = int(effect["heal"])
		GameManager.core_hp = mini(
			GameManager.core_hp + heal_amount,
			GameManager.STARTING_CORE_HP
		)

	if effect.has("power_cap"):
		GameManager.power_cap += int(effect["power_cap"])
		GameManager.power_changed.emit(GameManager.power_used, GameManager.power_cap)

	## Run-wide passive effects (stack additively)
	if effect.has("damage_mult"):
		run_damage_bonus += effect["damage_mult"]

	if effect.has("speed_mult"):
		run_speed_bonus += effect["speed_mult"]

	if effect.has("range_mult"):
		run_range_bonus += effect["range_mult"]

	if effect.has("cost_reduction"):
		run_cost_reduction += effect["cost_reduction"]

	if effect.has("sell_refund"):
		run_sell_refund = effect["sell_refund"]

	## Record in RunManager
	RunManager.choose_reward(reward)

	reward_applied.emit(reward)
	_current_choices.clear()


## Reset all run-wide bonuses for a new run.
func reset() -> void:
	run_damage_bonus = 0.0
	run_speed_bonus = 0.0
	run_range_bonus = 0.0
	run_cost_reduction = 0.0
	run_sell_refund = 0.70
	_current_choices.clear()


## Get the effective tower cost after run-wide discount.
func get_discounted_cost(base_cost: int) -> int:
	if run_cost_reduction <= 0.0:
		return base_cost
	return maxi(1, int(base_cost * (1.0 - run_cost_reduction)))


## Get the effective sell value after run-wide sell refund bonus.
func get_sell_value(total_invested: int) -> int:
	return int(total_invested * run_sell_refund)


## Get current choices (for UI to read).
func get_current_choices() -> Array:
	return _current_choices


## ============================================================================
## PRIVATE
## ============================================================================

func _load_reward_pool() -> void:
	var file := FileAccess.open("res://data/rewards.json", FileAccess.READ)
	if not file:
		push_error("RewardSystem: Failed to load rewards.json")
		return

	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()

	if err != OK:
		push_error("RewardSystem: JSON parse error in rewards.json")
		return

	var data: Dictionary = json.data
	_reward_pool = data.get("reward_pool", [])


## Weighted random selection of N unique items from a pool.
func _weighted_pick(pool: Array, count: int, _wave: int) -> Array:
	if pool.size() <= count:
		return pool.duplicate()

	var result: Array = []
	var remaining: Array = pool.duplicate()

	for i in count:
		var total_weight: float = 0.0
		for item in remaining:
			total_weight += item.get("weight", 1)

		var roll: float = RunManager.rng.randf() * total_weight
		var cumulative: float = 0.0

		for j in remaining.size():
			cumulative += remaining[j].get("weight", 1)
			if roll <= cumulative:
				result.append(remaining[j])
				remaining.remove_at(j)
				break

	return result
