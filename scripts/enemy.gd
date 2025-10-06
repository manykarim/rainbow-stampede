extends CharacterBody2D
class_name Enemy

@export var move_speed: float = 120.0
@export var damage: int = 10

@onready var health_component: HealthComponent = $HealthComponent
var _target: Node2D
var _pool: ObjectPool

func _ready() -> void:
    if health_component:
        health_component.died.connect(_on_died)

func setup(target: Node2D, pool: ObjectPool) -> void:
    _target = target
    _pool = pool
    if health_component:
        health_component.reset()

func _physics_process(delta: float) -> void:
    if _target == null:
        velocity = Vector2.ZERO
        return
    var direction := (_target.global_position - global_position).normalized()
    velocity = direction * move_speed
    move_and_slide()
    if global_position.distance_to(_target.global_position) < 20.0:
        _damage_player()

func _damage_player() -> void:
    if _target and _target.has_method("apply_hit"):
        _target.apply_hit(damage)
        if health_component:
            health_component.apply_damage(health_component.max_health)

func apply_hit(amount: int) -> void:
    if health_component:
        health_component.apply_damage(amount)

func _on_died() -> void:
    _recycle()

func _recycle() -> void:
    if _pool:
        _pool.recycle(self)
    else:
        queue_free()
