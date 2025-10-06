extends Area2D
class_name Bullet

@export var speed: float = 600.0
@export var lifetime: float = 2.0

var damage: int = 10
var _direction: Vector2 = Vector2.UP
var _time_alive: float = 0.0
var _pool: ObjectPool

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    monitoring = false

func launch(direction: Vector2, damage_amount: int, pool: ObjectPool) -> void:
    _direction = direction.normalized()
    damage = damage_amount
    _pool = pool
    _time_alive = 0.0
    rotation = _direction.angle()
    monitoring = true

func _physics_process(delta: float) -> void:
    position += _direction * speed * delta
    _time_alive += delta
    if _time_alive >= lifetime:
        _recycle()

func _on_body_entered(body: Node) -> void:
    if not monitoring:
        return
    if body.has_method("apply_hit"):
        body.apply_hit(damage)
    elif body.has_node("HealthComponent"):
        var hc: HealthComponent = body.get_node("HealthComponent")
        hc.apply_damage(damage)
    _recycle()

func _recycle() -> void:
    monitoring = false
    if _pool:
        _pool.recycle(self)
    else:
        queue_free()
