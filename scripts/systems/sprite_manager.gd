## ============================================================================
## SPRITE MANAGER
## ============================================================================
##
## Purpose: Centralized sprite loading for towers, enemies, and effects.
## Checks for sprite files at standard paths. Returns null if no sprite
## exists, allowing callers to fall back to _draw() rendering.
##
## Sprite paths follow ASSET_BIBLE.md naming conventions:
##   towers:  assets/sprites/towers/{tower_id}_lv{1-3}.png
##   enemies: assets/sprites/enemies/{enemy_id}.png
##   effects: assets/sprites/effects/{effect_name}.png
##
## @author Signal Lost Team
## @version 1.0.0
extends Node


## ============================================================================
## CACHE
## ============================================================================

var _cache: Dictionary = {}


## ============================================================================
## PUBLIC API
## ============================================================================

## Get tower sprite for a given tower_id and level.
## Returns null if no sprite file exists (caller should use _draw fallback).
func get_tower_sprite(tower_id: String, level: int = 1, branch: String = "") -> Texture2D:
	var path: String
	if branch != "" and level >= 2:
		path = "res://assets/sprites/towers/%s_lv%d_%s.png" % [tower_id, level, branch]
	else:
		path = "res://assets/sprites/towers/%s_lv%d.png" % [tower_id, level]
	return _load_texture(path)


## Get enemy sprite for a given enemy_id.
## Returns null if no sprite file exists.
func get_enemy_sprite(enemy_id: String) -> Texture2D:
	var path := "res://assets/sprites/enemies/%s.png" % enemy_id
	return _load_texture(path)


## Get effect sprite (projectile, explosion, etc).
## Returns null if no sprite file exists.
func get_effect_sprite(effect_name: String) -> Texture2D:
	var path := "res://assets/sprites/effects/%s.png" % effect_name
	return _load_texture(path)


## Check if a tower has sprites available (any level).
func has_tower_sprite(tower_id: String) -> bool:
	return get_tower_sprite(tower_id, 1) != null


## Check if an enemy has a sprite available.
func has_enemy_sprite(enemy_id: String) -> bool:
	return get_enemy_sprite(enemy_id) != null


## Clear the cache (useful after adding new sprites at runtime).
func clear_cache() -> void:
	_cache.clear()


## ============================================================================
## PRIVATE
## ============================================================================

func _load_texture(path: String) -> Texture2D:
	## Check cache first
	if _cache.has(path):
		return _cache[path]

	## Check if file exists
	if not ResourceLoader.exists(path):
		_cache[path] = null
		return null

	var texture: Texture2D = load(path) as Texture2D
	_cache[path] = texture
	return texture
