extends Node2D
class_name EnemySpawner

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.5
@export var spawn_radius: float = 420.0
@export var max_active_enemies: int = 6

var target: Node2D
var _timer: float = 0.0
var _pool: ObjectPool
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
    if enemy_scene == null:
        enemy_scene = preload("res://scenes/Enemy.tscn")
    _pool = ObjectPool.new()
    _pool.scene = enemy_scene
    _pool.initial_size = max_active_enemies
    _pool.name = "Pool"
    add_child(_pool)
    _timer = spawn_interval
    _rng.randomize()

func set_target(new_target: Node2D) -> void:
    target = new_target

func clear_enemies() -> void:
    if _pool:
        _pool.recycle_all()
    _timer = spawn_interval

func _process(delta: float) -> void:
    if target == null:
        return
    _timer -= delta
    if _timer <= 0.0 and _pool.get_active_count() < max_active_enemies:
        _spawn_enemy()
        _timer = spawn_interval

func _spawn_enemy() -> void:
    var instance := _pool.take()
    var spawn_pos := _random_position_around_target()
    if instance is Enemy:
        var enemy: Enemy = instance
        enemy.global_position = spawn_pos
        enemy.setup(target, _pool)
    else:
        instance.global_position = spawn_pos
        if instance.has_method("setup"):
            instance.setup(target, _pool)

func _random_position_around_target() -> Vector2:
    var angle := _rng.randf_range(0.0, TAU)
    return target.global_position + Vector2.RIGHT.rotated(angle) * spawn_radius
