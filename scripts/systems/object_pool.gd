## ============================================================================
## OBJECT POOL
## ============================================================================
##
## Purpose: Reusable object pool to avoid instantiate/queue_free overhead.
## Used for enemies, projectiles, and VFX.
##
## Usage:
##   var pool = ObjectPool.new(enemy_scene, 50)
##   add_child(pool)
##   var enemy = pool.acquire()
##   pool.release(enemy)
##
## @author Signal Lost Team
## @version 0.1.0
class_name ObjectPool
extends Node


## ============================================================================
## STATE
## ============================================================================

var _scene: PackedScene
var _available: Array[Node] = []
var _active: Array[Node] = []
var _initial_size: int


## ============================================================================
## LIFECYCLE
## ============================================================================

func _init(scene: PackedScene, initial_size: int = 20) -> void:
	_scene = scene
	_initial_size = initial_size


func _ready() -> void:
	for i in _initial_size:
		_create_instance()


## ============================================================================
## PUBLIC API
## ============================================================================

## Get an object from the pool. Returns null if pool is exhausted (auto-grows).
func acquire() -> Node:
	var instance: Node
	if _available.size() > 0:
		instance = _available.pop_back()
	else:
		instance = _create_instance()

	_active.append(instance)
	instance.visible = true
	instance.set_process(true)
	instance.set_physics_process(true)

	if instance.has_method("on_pool_acquire"):
		instance.on_pool_acquire()

	return instance


## Return an object to the pool.
func release(instance: Node) -> void:
	if instance in _active:
		_active.erase(instance)

	if instance not in _available:
		_available.append(instance)

	instance.visible = false
	instance.set_process(false)
	instance.set_physics_process(false)

	if instance.has_method("on_pool_release"):
		instance.on_pool_release()


## Release all active objects back to the pool.
func release_all() -> void:
	for instance in _active.duplicate():
		release(instance)


## Get count of currently active objects.
func active_count() -> int:
	return _active.size()


## Get count of available objects in pool.
func available_count() -> int:
	return _available.size()


## ============================================================================
## PRIVATE
## ============================================================================

func _create_instance() -> Node:
	var instance := _scene.instantiate()
	add_child(instance)
	instance.visible = false
	instance.set_process(false)
	instance.set_physics_process(false)
	_available.append(instance)
	return instance
