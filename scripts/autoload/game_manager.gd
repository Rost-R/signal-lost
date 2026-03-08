## ============================================================================
## GAME MANAGER (Autoload Singleton)
## ============================================================================
##
## Purpose: Manages the current game state during a wave/build phase.
## Tracks resources, core HP, current wave, and game-over conditions.
##
## Access: GameManager (global singleton)
##
## @author Signal Lost Team
## @version 0.1.0
extends Node


## ============================================================================
## SIGNALS
## ============================================================================

signal scrap_changed(new_amount: int)
signal power_changed(used: int, cap: int)
signal core_hp_changed(new_hp: int)
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal game_over(victory: bool)
signal game_phase_changed(phase: GamePhase)
signal signal_charge_changed(charge: float, max_charge: float)


## ============================================================================
## ENUMS
## ============================================================================

enum GamePhase {
	BUILD,
	WAVE,
	BETWEEN_WAVES,
	REWARD_CHOICE,
	BOSS,
	GAME_OVER
}

enum TargetPriority {
	FIRST,
	LAST,
	STRONGEST,
	WEAKEST
}


## ============================================================================
## CONSTANTS
## ============================================================================

const STARTING_SCRAP := 140
const STARTING_CORE_HP := 20
const MAX_WAVES := 10
const STARTING_POWER_CAP := 8


## ============================================================================
## STATE
## ============================================================================

var scrap: int = STARTING_SCRAP:
	set(value):
		scrap = max(0, value)
		scrap_changed.emit(scrap)

var power_used: int = 0
var power_cap: int = STARTING_POWER_CAP

var core_hp: int = STARTING_CORE_HP:
	set(value):
		core_hp = max(0, value)
		core_hp_changed.emit(core_hp)
		if core_hp <= 0:
			_trigger_game_over(false)

var current_wave: int = 0
var current_phase: GamePhase = GamePhase.BUILD
var is_running: bool = false
var default_target_priority: TargetPriority = TargetPriority.FIRST

## Tracks core HP at wave start to detect flawless waves (no damage taken).
var core_hp_before_wave: int = STARTING_CORE_HP

## Signal Charge — fills during combat, spends on resonance abilities.
var signal_charge: float = 0.0
var signal_charge_max: float = 100.0
const CHARGE_PER_ATTACK := 0.5      ## Charge gained per tower attack
const CHARGE_PER_KILL := 3.0        ## Charge gained per enemy kill
const CHARGE_PER_WAVE_CLEAR := 10.0 ## Charge gained when wave clears


## ============================================================================
## LIFECYCLE
## ============================================================================

func _ready() -> void:
	pass


## ============================================================================
## PUBLIC API
## ============================================================================

## Reset all game state for a new run.
func reset() -> void:
	scrap = STARTING_SCRAP
	power_used = 0
	power_cap = STARTING_POWER_CAP
	core_hp = STARTING_CORE_HP
	current_wave = 0
	current_phase = GamePhase.BUILD
	is_running = false
	core_hp_before_wave = STARTING_CORE_HP
	signal_charge = 0.0


## Start a new run with optional modifier adjustments.
func start_run(starting_scrap_override: int = -1, starting_hp_override: int = -1) -> void:
	reset()
	if starting_scrap_override > 0:
		scrap = starting_scrap_override
	if starting_hp_override > 0:
		core_hp = starting_hp_override
	is_running = true
	_set_phase(GamePhase.BUILD)


## Begin the next wave.
func start_wave() -> void:
	current_wave += 1
	core_hp_before_wave = core_hp
	_set_phase(GamePhase.WAVE)
	wave_started.emit(current_wave)


## Called when all enemies in the current wave are defeated.
## Non-boss waves transition to REWARD_CHOICE; boss wave = victory.
func complete_wave() -> void:
	RunManager.waves_survived = current_wave
	add_signal_charge(CHARGE_PER_WAVE_CLEAR)
	wave_completed.emit(current_wave)
	if current_wave >= MAX_WAVES:
		_trigger_game_over(true)
	else:
		_set_phase(GamePhase.REWARD_CHOICE)


## Called after player picks a reward. Transition to build phase.
func finish_reward_choice() -> void:
	_set_phase(GamePhase.BETWEEN_WAVES)


## Apply damage to the relay core.
func damage_core(amount: int) -> void:
	core_hp -= amount


## Add scrap (from killing enemies, Salvage Matrix, etc.).
func add_scrap(amount: int) -> void:
	scrap += amount


## Spend scrap (tower placement, upgrades). Returns false if insufficient.
func spend_scrap(amount: int) -> bool:
	if scrap >= amount:
		scrap -= amount
		return true
	return false


## Check if there is enough power to place a tower.
func can_use_power(cost: int) -> bool:
	return power_used + cost <= power_cap


## Use power when placing a tower.
func use_power(cost: int) -> bool:
	if not can_use_power(cost):
		return false
	power_used += cost
	power_changed.emit(power_used, power_cap)
	return true


## Release power when selling a tower.
func release_power(cost: int) -> void:
	power_used = max(0, power_used - cost)
	power_changed.emit(power_used, power_cap)


## Add to power cap (e.g. from power nodes or upgrades).
func add_power_cap(amount: int) -> void:
	power_cap += amount
	power_changed.emit(power_used, power_cap)


## Remove from power cap (e.g. when selling tower on power node).
func remove_power_cap(amount: int) -> void:
	power_cap = maxi(1, power_cap - amount)
	power_changed.emit(power_used, power_cap)


## Add signal charge (from combat events).
func add_signal_charge(amount: float) -> void:
	signal_charge = clampf(signal_charge + amount, 0.0, signal_charge_max)
	signal_charge_changed.emit(signal_charge, signal_charge_max)


## Spend signal charge (on resonance abilities). Returns false if insufficient.
func spend_signal_charge(amount: float) -> bool:
	if signal_charge >= amount:
		signal_charge -= amount
		signal_charge_changed.emit(signal_charge, signal_charge_max)
		return true
	return false


## ============================================================================
## PRIVATE
## ============================================================================

func _set_phase(phase: GamePhase) -> void:
	current_phase = phase
	game_phase_changed.emit(phase)


func _trigger_game_over(victory: bool) -> void:
	is_running = false
	_set_phase(GamePhase.GAME_OVER)
	game_over.emit(victory)
