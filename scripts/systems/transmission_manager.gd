## ============================================================================
## TRANSMISSION MANAGER
## ============================================================================
##
## Purpose: Manages story transmissions — loading, unlocking, offering as
## choices during between-wave story windows, and tracking which transmissions
## the player has seen. Transmissions are semi-random based on unlock_priority
## and unlock_weight, seeded by RunManager.rng.
##
## @author Signal Lost Team
## @version 0.2.0
class_name TransmissionManager
extends Node


## ============================================================================
## SIGNALS
## ============================================================================

signal transmission_offered(choices: Array)
signal transmission_selected(transmission: Dictionary)
signal transmission_displayed(transmission: Dictionary)


## ============================================================================
## STATE
## ============================================================================

var _transmission_data: Dictionary = {}
var _endings_data: Dictionary = {}

## Per-run state
var _seen_this_run: Array[String] = []  ## tx_ids seen in current run
var _unlocked_pool: Array[String] = []  ## tx_ids available to be offered

## Per-session (meta) state — persisted via MetaManager
var _ever_unlocked: Array[String] = []  ## tx_ids unlocked across all runs

## Story window frequency: offer transmissions every N waves
const STORY_WINDOW_INTERVAL := 2  ## Waves 2, 4, 6, 8


## ============================================================================
## LIFECYCLE
## ============================================================================

func _ready() -> void:
	_load_transmission_data()


## ============================================================================
## PUBLIC API
## ============================================================================

## Reset for a new run.
func reset() -> void:
	_seen_this_run.clear()
	_build_unlock_pool()


## Check if a story window should appear after this wave.
func is_story_window(wave_number: int) -> bool:
	return wave_number > 0 and wave_number % STORY_WINDOW_INTERVAL == 0 and wave_number < 10


## Generate 1-2 transmission choices for a story window.
## Returns array of transmission dictionaries with tx_id added.
func generate_choices(wave_number: int) -> Array:
	var available := _get_available_transmissions(wave_number)
	if available.is_empty():
		return []

	## Pick 1-2 choices using weighted random
	var count := mini(2, available.size())
	var choices: Array = []

	for i in count:
		if available.is_empty():
			break
		var picked := _weighted_pick(available)
		if picked != "":
			var tx := _get_transmission(picked)
			tx["tx_id"] = picked
			choices.append(tx)
			available.erase(picked)

	return choices


## Mark a transmission as seen/selected in this run.
func select_transmission(tx_id: String) -> void:
	if tx_id not in _seen_this_run:
		_seen_this_run.append(tx_id)
	if tx_id not in _ever_unlocked:
		_ever_unlocked.append(tx_id)
	RunManager.transmissions_seen.append(tx_id)


## Get all transmissions seen this run.
func get_seen_this_run() -> Array[String]:
	return _seen_this_run


## Check if an ending's requirements are met.
func check_ending_conditions() -> String:
	for ending_id in _endings_data:
		var ending: Dictionary = _endings_data[ending_id]
		var required: Array = ending.get("required_transmissions", [])
		if required.is_empty():
			continue
		var all_met := true
		for req_tx in required:
			if req_tx not in _ever_unlocked:
				all_met = false
				break
		if all_met:
			return ending_id
	return ""


## ============================================================================
## PRIVATE
## ============================================================================

## Build the pool of transmissions available this run.
func _build_unlock_pool() -> void:
	_unlocked_pool.clear()
	for tx_id in _transmission_data:
		_unlocked_pool.append(tx_id)


## Get transmissions eligible for offering at this wave.
func _get_available_transmissions(wave_number: int) -> Array[String]:
	var available: Array[String] = []
	for tx_id in _unlocked_pool:
		if tx_id in _seen_this_run:
			continue
		var tx: Dictionary = _transmission_data.get(tx_id, {})
		## Check unlock_priority — higher priority transmissions unlock earlier
		var priority: int = tx.get("unlock_priority", 99)
		## Allow transmissions with priority <= wave * 2.5 (so wave 2 allows priority 1-5)
		if priority <= int(wave_number * 2.5):
			available.append(tx_id)
	return available


## Weighted random pick from available transmissions.
func _weighted_pick(available: Array[String]) -> String:
	if available.is_empty():
		return ""
	var total_weight := 0.0
	for tx_id in available:
		var tx: Dictionary = _transmission_data.get(tx_id, {})
		total_weight += tx.get("unlock_weight", 1)

	var roll := RunManager.rng.randf() * total_weight
	var cumulative := 0.0
	for tx_id in available:
		var tx: Dictionary = _transmission_data.get(tx_id, {})
		cumulative += tx.get("unlock_weight", 1)
		if roll <= cumulative:
			return tx_id

	return available[0]


## Get a transmission dictionary by ID.
func _get_transmission(tx_id: String) -> Dictionary:
	return _transmission_data.get(tx_id, {}).duplicate()


## ============================================================================
## DATA LOADING
## ============================================================================

func _load_transmission_data() -> void:
	var file := FileAccess.open("res://data/transmissions.json", FileAccess.READ)
	if file:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK:
			var data: Dictionary = json.data
			_transmission_data = data.get("transmissions", {})
			_endings_data = data.get("endings", {})
		file.close()
