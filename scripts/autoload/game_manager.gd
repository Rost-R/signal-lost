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

signal resources_changed(new_amount: int)
signal core_hp_changed(new_hp: int)
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal game_over(victory: bool)
signal game_phase_changed(phase: GamePhase)


## ============================================================================
## ENUMS
## ============================================================================

enum GamePhase {
	BUILD,
	WAVE,
	BETWEEN_WAVES,
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

const STARTING_RESOURCES := 350
const STARTING_CORE_HP := 20
const MAX_WAVES := 8


## ============================================================================
## STATE
## ============================================================================

var resources: int = STARTING_RESOURCES:
	set(value):
		resources = max(0, value)
		resources_changed.emit(resources)

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
	resources = STARTING_RESOURCES
	core_hp = STARTING_CORE_HP
	current_wave = 0
	current_phase = GamePhase.BUILD
	is_running = false


## Start a new run with optional modifier adjustments.
func start_run(starting_resources_override: int = -1, starting_hp_override: int = -1) -> void:
	reset()
	if starting_resources_override > 0:
		resources = starting_resources_override
	if starting_hp_override > 0:
		core_hp = starting_hp_override
	is_running = true
	_set_phase(GamePhase.BUILD)


## Begin the next wave.
func start_wave() -> void:
	current_wave += 1
	_set_phase(GamePhase.WAVE)
	wave_started.emit(current_wave)


## Called when all enemies in the current wave are defeated.
func complete_wave() -> void:
	wave_completed.emit(current_wave)
	if current_wave >= MAX_WAVES:
		_trigger_game_over(true)
	else:
		_set_phase(GamePhase.BETWEEN_WAVES)


## Apply damage to the relay core.
func damage_core(amount: int) -> void:
	core_hp -= amount


## Add resources (from killing enemies, Data Siphon, etc.).
func add_resources(amount: int) -> void:
	resources += amount


## Spend resources (tower placement, upgrades). Returns false if insufficient.
func spend_resources(amount: int) -> bool:
	if resources >= amount:
		resources -= amount
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
