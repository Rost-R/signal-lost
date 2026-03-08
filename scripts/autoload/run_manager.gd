## ============================================================================
## RUN MANAGER (Autoload Singleton)
## ============================================================================
##
## Purpose: Manages per-run state — modifiers, chosen rewards, seed.
## Reset at the start of each new run. Lost on death.
##
## Access: RunManager (global singleton)
##
## @author Signal Lost Team
## @version 0.1.0
extends Node


## ============================================================================
## SIGNALS
## ============================================================================

signal modifier_applied(modifier_id: String)
signal reward_chosen(reward_data: Dictionary)


## ============================================================================
## STATE
## ============================================================================

## The random seed for this run (enables Daily Challenge reproducibility).
var run_seed: int = 0

## RNG instance seeded for this run.
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

## Active modifiers for this run (modifier IDs from modifiers.json).
var active_modifiers: Array[String] = []

## Rewards chosen between waves this run.
var chosen_rewards: Array[Dictionary] = []

## Tower upgrades applied this run (tower_id -> upgrade_level).
var tower_upgrades: Dictionary = {}

## How many waves survived this run (for stats).
var waves_survived: int = 0

## Total enemies killed this run.
var enemies_killed: int = 0

## Total resources earned this run.
var resources_earned: int = 0


## ============================================================================
## PUBLIC API
## ============================================================================

## Start a new run with an optional seed (0 = random).
func start_new_run(seed: int = 0) -> void:
	if seed == 0:
		run_seed = randi()
	else:
		run_seed = seed
	rng.seed = run_seed
	active_modifiers.clear()
	chosen_rewards.clear()
	tower_upgrades.clear()
	waves_survived = 0
	enemies_killed = 0
	resources_earned = 0


## Apply a run modifier by ID.
func apply_modifier(modifier_id: String) -> void:
	if modifier_id not in active_modifiers:
		active_modifiers.append(modifier_id)
		modifier_applied.emit(modifier_id)


## Check if a modifier is active.
func has_modifier(modifier_id: String) -> bool:
	return modifier_id in active_modifiers


## Record a between-wave reward choice.
func choose_reward(reward_data: Dictionary) -> void:
	chosen_rewards.append(reward_data)
	reward_chosen.emit(reward_data)


## Get run summary for end-of-run stats screen.
func get_run_summary() -> Dictionary:
	return {
		"seed": run_seed,
		"waves_survived": waves_survived,
		"enemies_killed": enemies_killed,
		"resources_earned": resources_earned,
		"modifiers": active_modifiers.duplicate(),
		"rewards": chosen_rewards.duplicate(),
	}
