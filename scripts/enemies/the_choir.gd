## ============================================================================
## THE CHOIR (BOSS 1)
## ============================================================================
##
## Purpose: Wave 10 boss. Spawns echo units periodically. Strengthens from
## unbroken passes. Tests multi-lane response and sustained DPS.
##
## @author Signal Lost Team
## @version 0.1.0
class_name TheChoir
extends "res://scripts/enemies/enemy_base.gd"

## GridManagerScript inherited from EnemyBase via preload()


## ============================================================================
## CONSTANTS
## ============================================================================

const ECHO_SPAWN_INTERVAL := 6.0  # Seconds between echo spawns
const ECHO_HP_RATIO := 0.1        # Each echo has 10% of boss HP
const ECHO_SPEED_MULT := 1.5
const MAX_ECHOES := 4


## ============================================================================
## STATE
## ============================================================================

var _echo_timer: float = ECHO_SPAWN_INTERVAL
var _echoes_spawned: int = 0


## ============================================================================
## LIFECYCLE
## ============================================================================

func _init() -> void:
	enemy_id = "the_choir"
	enemy_name = "The Choir"
	max_hp = 2500.0
	base_speed = 25.0
	damage_to_core = 10
	armor = 15.0
	reward = 250
	enemy_color = Color(0.67, 0.27, 1)  # #AA44FF — boss purple
	_size_scale = 1.8


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	## Spawn echo units periodically
	if visible and not _is_frozen and _echoes_spawned < MAX_ECHOES:
		_echo_timer -= delta
		if _echo_timer <= 0:
			_spawn_echo()
			_echo_timer = ECHO_SPAWN_INTERVAL


## ============================================================================
## ECHO SPAWNING
## ============================================================================

func _spawn_echo() -> void:
	_echoes_spawned += 1

	## Create a simple echo enemy (GlitchSwarm-like with boss coloring)
	var echo := Node2D.new()
	var echo_script: GDScript = preload("res://scripts/enemies/glitch_swarm.gd")
	echo.set_script(echo_script)
	get_parent().add_child(echo)

	## Override echo stats
	echo.enemy_id = "choir_echo"
	echo.enemy_name = "Choir Echo"
	echo.max_hp = max_hp * ECHO_HP_RATIO
	echo.base_speed = base_speed * ECHO_SPEED_MULT
	echo.damage_to_core = 1
	echo.armor = 0.0
	echo.reward = 10
	echo.enemy_color = Color(0.8, 0.5, 1)  # Lighter purple
	echo._size_scale = 0.5

	## Set up path from current position
	var remaining_path := PackedVector2Array()
	for i in range(_path_index, _path.size()):
		remaining_path.append(_path[i])

	if remaining_path.size() > 0:
		echo.setup(remaining_path, 1.0)
		## Connect signals to parent's wave spawner
		if get_parent().has_method("_on_enemy_died"):
			echo.enemy_died.connect(get_parent()._on_enemy_died)
		if get_parent().has_method("_on_enemy_reached_core"):
			echo.enemy_reached_core.connect(get_parent()._on_enemy_reached_core)
	else:
		echo.queue_free()


## ============================================================================
## DRAWING
## ============================================================================

func _draw_enemy() -> void:
	var size := GridManagerScript.CELL_SIZE * _size_scale * 0.4
	var color := enemy_color

	if _hit_flash_timer > 0:
		color = Color.WHITE
	if _is_frozen:
		color = Color(0.53, 0.87, 1)

	## HP-based color shift (gets angrier at low HP)
	var hp_ratio := clampf(current_hp / max_hp, 0.0, 1.0)
	if hp_ratio < 0.33:
		color = color.lerp(Color(1, 0.13, 0.27), 0.5)
	elif hp_ratio < 0.66:
		color = color.lerp(Color(1, 0.73, 0), 0.3)

	## Pulsing outer aura with multiple rings (choir effect)
	var pulse := sin(Time.get_ticks_msec() * 0.004) * 0.1 + 0.9
	draw_arc(Vector2.ZERO, size * 1.5 * pulse, 0, TAU, 48, Color(color, 0.15), 2.0)
	var pulse2 := sin(Time.get_ticks_msec() * 0.003 + 1.0) * 0.1 + 0.8
	draw_arc(Vector2.ZERO, size * 1.2 * pulse2, 0, TAU, 36, Color(color, 0.1), 1.5)

	## Hexagonal boss body
	var points := PackedVector2Array()
	for i in 6:
		var angle := deg_to_rad(60 * i)
		points.append(Vector2(cos(angle), sin(angle)) * size)
	draw_colored_polygon(points, Color(color, 0.6))
	draw_polyline(points + PackedVector2Array([points[0]]), color, 3.0)

	## Inner core with echo count indicator
	draw_circle(Vector2.ZERO, size * 0.3, Color(color, 0.8 * pulse))

	## Echo spawn indicators
	for i in MAX_ECHOES:
		var dot_x := (i - (MAX_ECHOES - 1) * 0.5) * 8.0
		var dot_color := Color(0.8, 0.5, 1) if i < _echoes_spawned else Color(color, 0.3)
		draw_circle(Vector2(dot_x, size + 10), 2.5, dot_color)

	_draw_hp_bar(size)
