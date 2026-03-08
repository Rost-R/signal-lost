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
var _endings_unlocked: Array[String] = []  ## ending IDs seen across all runs

## Truth axes — accumulated from transmission ending_tracks this run
var truth_axes: Dictionary = {
	"crew_fault": 0.0,
	"core_fault": 0.0,
	"signal_truth": 0.0,
}

## Mapping from ending_track to truth axis
const TRACK_TO_AXIS := {
	"resistance": "crew_fault",
	"corruption": "core_fault",
	"signal_origin": "signal_truth",
	"transcendence": "signal_truth",
}

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
	truth_axes = { "crew_fault": 0.0, "core_fault": 0.0, "signal_truth": 0.0 }
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

	## Accumulate truth axes based on ending_track
	var tx: Dictionary = _transmission_data.get(tx_id, {})
	var track: String = tx.get("ending_track", "none")
	if track in TRACK_TO_AXIS:
		var axis: String = TRACK_TO_AXIS[track]
		truth_axes[axis] += 1.0


## Get all transmissions seen this run.
func get_seen_this_run() -> Array[String]:
	return _seen_this_run


## Determine which ending the player gets based on truth axes and conditions.
## Called at end of run. Returns ending dictionary with id, name, description.
func determine_ending(victory: bool) -> Dictionary:
	## Check synthesis first (requires all 3 other endings across runs)
	if _check_synthesis_ending():
		var ending: Dictionary = _endings_data.get("synthesis", {}).duplicate()
		ending["id"] = "synthesis"
		_record_ending("synthesis")
		return ending

	## Signal Origin: all signal transmissions unlocked across runs
	if _check_transmission_requirements("signal_origin"):
		var ending: Dictionary = _endings_data.get("signal_origin", {}).duplicate()
		ending["id"] = "signal_origin"
		_record_ending("signal_origin")
		return ending

	## Determine by dominant truth axis this run
	var dominant := _get_dominant_axis()

	## Transcendence: signal_truth dominant AND player lost (core destroyed)
	if dominant == "signal_truth" and not victory:
		var ending: Dictionary = _endings_data.get("transcendence", {}).duplicate()
		ending["id"] = "transcendence"
		_record_ending("transcendence")
		return ending

	## Resistance: crew_fault dominant OR victory with core_fault
	if dominant == "crew_fault" or (victory and dominant == "core_fault"):
		var ending: Dictionary = _endings_data.get("resistance", {}).duplicate()
		ending["id"] = "resistance"
		_record_ending("resistance")
		return ending

	## Default: resistance for victory, transcendence for loss
	var default_id := "resistance" if victory else "transcendence"
	var ending: Dictionary = _endings_data.get(default_id, {}).duplicate()
	ending["id"] = default_id
	_record_ending(default_id)
	return ending


## Get the dominant truth axis for this run.
func _get_dominant_axis() -> String:
	var max_val := 0.0
	var dominant := "crew_fault"
	for axis in truth_axes:
		if truth_axes[axis] > max_val:
			max_val = truth_axes[axis]
			dominant = axis
	return dominant


## Check if all required transmissions for an ending are unlocked.
func _check_transmission_requirements(ending_id: String) -> bool:
	var ending: Dictionary = _endings_data.get(ending_id, {})
	var required: Array = ending.get("required_transmissions", [])
	if required.is_empty():
		return false
	for req_tx in required:
		if req_tx not in _ever_unlocked:
			return false
	return true


## Check synthesis ending (all 3 other endings seen across runs via MetaManager).
func _check_synthesis_ending() -> bool:
	var synthesis: Dictionary = _endings_data.get("synthesis", {})
	var required: Array = synthesis.get("required_endings", [])
	if required.is_empty():
		return false
	for req_end in required:
		if not MetaManager.is_ending_unlocked(req_end):
			return false
	return true


## Record an ending as seen (delegates to MetaManager for persistence).
func _record_ending(ending_id: String) -> void:
	MetaManager.unlock_ending(ending_id)
	if ending_id not in _endings_unlocked:
		_endings_unlocked.append(ending_id)


## Get all endings unlocked across runs.
func get_unlocked_endings() -> Array[String]:
	return _endings_unlocked


## Get truth axes values for display.
func get_truth_axes() -> Dictionary:
	return truth_axes.duplicate()


## Restore meta state from save data.
func restore_meta(ever_unlocked: Array, endings: Array) -> void:
	_ever_unlocked = ever_unlocked.duplicate()
	_endings_unlocked = endings.duplicate()


## Get meta state for saving.
func get_meta_state() -> Dictionary:
	return {
		"ever_unlocked": _ever_unlocked.duplicate(),
		"endings_unlocked": _endings_unlocked.duplicate(),
	}


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
