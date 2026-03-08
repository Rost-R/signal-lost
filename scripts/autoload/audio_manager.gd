## ============================================================================
## AUDIO MANAGER (Autoload Singleton)
## ============================================================================
##
## Purpose: Centralized audio control for music and SFX.
## Manages volume, crossfading between tracks, and sound pooling.
##
## Access: AudioManager (global singleton)
##
## @author Signal Lost Team
## @version 0.1.0
extends Node


## ============================================================================
## CONSTANTS
## ============================================================================

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"
const CROSSFADE_DURATION := 1.5


## ============================================================================
## STATE
## ============================================================================

var music_volume: float = 0.8:
	set(value):
		music_volume = clampf(value, 0.0, 1.0)
		_apply_music_volume()

var sfx_volume: float = 0.8:
	set(value):
		sfx_volume = clampf(value, 0.0, 1.0)
		_apply_sfx_volume()

var _current_music: AudioStreamPlayer = null
var _sfx_pool: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE := 8


## ============================================================================
## LIFECYCLE
## ============================================================================

func _ready() -> void:
	_setup_sfx_pool()


## ============================================================================
## PUBLIC API
## ============================================================================

## Play a music track (crossfades if another is playing).
func play_music(stream: AudioStream) -> void:
	if _current_music and _current_music.playing:
		var tween := create_tween()
		tween.tween_property(_current_music, "volume_db", -80.0, CROSSFADE_DURATION)
		tween.tween_callback(_current_music.stop)

	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream = stream
	player.volume_db = linear_to_db(music_volume)
	player.bus = MUSIC_BUS
	player.play()

	if _current_music and is_instance_valid(_current_music):
		# Clean up old player after crossfade
		var old := _current_music
		get_tree().create_timer(CROSSFADE_DURATION + 0.1).timeout.connect(
			func(): old.queue_free()
		)

	_current_music = player


## Stop the current music track.
func stop_music() -> void:
	if _current_music and _current_music.playing:
		var tween := create_tween()
		tween.tween_property(_current_music, "volume_db", -80.0, CROSSFADE_DURATION)
		tween.tween_callback(_current_music.stop)


## Play a one-shot sound effect.
func play_sfx(stream: AudioStream, pitch_variation: float = 0.0) -> void:
	for player in _sfx_pool:
		if not player.playing:
			player.stream = stream
			player.volume_db = linear_to_db(sfx_volume)
			if pitch_variation > 0.0:
				player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
			else:
				player.pitch_scale = 1.0
			player.play()
			return
	# All pool slots busy — skip this SFX (not critical)


## ============================================================================
## PRIVATE
## ============================================================================

func _setup_sfx_pool() -> void:
	for i in SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = SFX_BUS
		add_child(player)
		_sfx_pool.append(player)


func _apply_music_volume() -> void:
	if _current_music and is_instance_valid(_current_music):
		_current_music.volume_db = linear_to_db(music_volume)


func _apply_sfx_volume() -> void:
	for player in _sfx_pool:
		player.volume_db = linear_to_db(sfx_volume)
