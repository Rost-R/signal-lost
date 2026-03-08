## ============================================================================
## META MANAGER (Autoload Singleton)
## ============================================================================
##
## Purpose: Manages permanent meta-progression that persists across runs.
## Unlocked towers, transmissions, station upgrades, synergy discoveries.
## Handles save/load to disk.
##
## Access: MetaManager (global singleton)
##
## @author Signal Lost Team
## @version 0.1.0
extends Node


## ============================================================================
## SIGNALS
## ============================================================================

signal tower_unlocked(tower_id: String)
signal transmission_unlocked(transmission_id: String)
signal upgrade_purchased(upgrade_id: String)
signal synergy_discovered(synergy_id: String)


## ============================================================================
## CONSTANTS
## ============================================================================

const SAVE_PATH := "user://meta_save.json"

## Towers available from the start (before any unlocks).
const STARTING_TOWERS: Array[String] = ["pulse_emitter", "arc_relay", "cryo_node"]


## ============================================================================
## STATE
## ============================================================================

## Decoded Transmissions currency (earned from completed runs).
var decoded_transmissions: int = 0

## Unlocked tower blueprint IDs.
var unlocked_towers: Array[String] = []

## Unlocked transmission IDs (story fragments).
var unlocked_transmissions: Array[String] = []

## Purchased station upgrade IDs.
var purchased_upgrades: Array[String] = []

## Discovered synergy combination IDs.
var discovered_synergies: Array[String] = []

## Total runs completed (win or lose).
var total_runs: int = 0

## Total runs won.
var total_wins: int = 0

## Best wave reached across all runs.
var best_wave: int = 0


## ============================================================================
## LIFECYCLE
## ============================================================================

func _ready() -> void:
	_load_from_disk()


## ============================================================================
## PUBLIC API
## ============================================================================

## Initialize meta state for a fresh save (first time playing).
func initialize_fresh() -> void:
	decoded_transmissions = 0
	unlocked_towers = STARTING_TOWERS.duplicate()
	unlocked_transmissions.clear()
	purchased_upgrades.clear()
	discovered_synergies.clear()
	total_runs = 0
	total_wins = 0
	best_wave = 0
	save_to_disk()


## Check if a tower is unlocked.
func is_tower_unlocked(tower_id: String) -> bool:
	return tower_id in unlocked_towers


## Unlock a new tower blueprint.
func unlock_tower(tower_id: String) -> void:
	if tower_id not in unlocked_towers:
		unlocked_towers.append(tower_id)
		tower_unlocked.emit(tower_id)
		save_to_disk()


## Unlock a transmission (story fragment).
func unlock_transmission(transmission_id: String) -> void:
	if transmission_id not in unlocked_transmissions:
		unlocked_transmissions.append(transmission_id)
		transmission_unlocked.emit(transmission_id)
		save_to_disk()


## Record end-of-run results and award currency.
func record_run_end(waves_survived: int, victory: bool, currency_earned: int) -> void:
	total_runs += 1
	if victory:
		total_wins += 1
	if waves_survived > best_wave:
		best_wave = waves_survived
	decoded_transmissions += currency_earned
	save_to_disk()


## Discover a synergy for the first time.
func discover_synergy(synergy_id: String) -> void:
	if synergy_id not in discovered_synergies:
		discovered_synergies.append(synergy_id)
		synergy_discovered.emit(synergy_id)
		save_to_disk()


## ============================================================================
## SAVE / LOAD
## ============================================================================

func save_to_disk() -> void:
	var save_data := {
		"decoded_transmissions": decoded_transmissions,
		"unlocked_towers": unlocked_towers,
		"unlocked_transmissions": unlocked_transmissions,
		"purchased_upgrades": purchased_upgrades,
		"discovered_synergies": discovered_synergies,
		"total_runs": total_runs,
		"total_wins": total_wins,
		"best_wave": best_wave,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()


func _load_from_disk() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		initialize_fresh()
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		initialize_fresh()
		return

	var json := JSON.new()
	var parse_result := json.parse(file.get_as_text())
	file.close()

	if parse_result != OK:
		push_warning("MetaManager: Failed to parse save file, initializing fresh.")
		initialize_fresh()
		return

	var data: Dictionary = json.data
	decoded_transmissions = data.get("decoded_transmissions", 0)
	unlocked_towers = Array(data.get("unlocked_towers", STARTING_TOWERS), TYPE_STRING, "", null)
	unlocked_transmissions = Array(data.get("unlocked_transmissions", []), TYPE_STRING, "", null)
	purchased_upgrades = Array(data.get("purchased_upgrades", []), TYPE_STRING, "", null)
	discovered_synergies = Array(data.get("discovered_synergies", []), TYPE_STRING, "", null)
	total_runs = data.get("total_runs", 0)
	total_wins = data.get("total_wins", 0)
	best_wave = data.get("best_wave", 0)
