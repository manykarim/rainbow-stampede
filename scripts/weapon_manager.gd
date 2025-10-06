extends Node2D
class_name WeaponManager

@export var fire_rate: float = 3.0
@export var damage: int = 15
@export var bullet_scene: PackedScene
@export var auto_fire: bool = true
@export var muzzle_offset: Vector2 = Vector2(0, -24)

var _cooldown: float = 0.0
var _pool: ObjectPool

func _ready() -> void:
    if bullet_scene == null:
        bullet_scene = preload("res://scenes/Bullet.tscn")
    _pool = ObjectPool.new()
    _pool.scene = bullet_scene
    _pool.initial_size = 16
    add_child(_pool)

func update_weapon(delta: float, direction: Vector2) -> void:
    if auto_fire or Input.is_action_pressed("fire"):
        _cooldown -= delta
        if _cooldown <= 0.0:
            _fire(direction)
            _cooldown = 1.0 / fire_rate if fire_rate > 0.0 else 0.0
    else:
        _cooldown = min(_cooldown - delta, 0.0)

func stop_firing() -> void:
    _cooldown = 0.0

func _fire(direction: Vector2) -> void:
    if direction == Vector2.ZERO:
        direction = Vector2.UP
    var bullet_instance := _pool.take()
    var offset := muzzle_offset.rotated(direction.angle())
    var spawn_position := global_position + offset
    if bullet_instance is Bullet:
        var bullet: Bullet = bullet_instance
        bullet.global_position = spawn_position
        bullet.launch(direction, damage, _pool)
    else:
        bullet_instance.global_position = spawn_position
        if bullet_instance.has_method("launch"):
            bullet_instance.launch(direction, damage, _pool)
