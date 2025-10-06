extends Node
class_name HealthComponent

signal health_changed(current: int, max: int)
signal died

@export var max_health: int = 50
var current_health: int

func _ready() -> void:
    reset()

func apply_damage(amount: int) -> void:
    current_health = max(current_health - amount, 0)
    emit_signal("health_changed", current_health, max_health)
    if current_health == 0:
        emit_signal("died")

func heal(amount: int) -> void:
    current_health = clamp(current_health + amount, 0, max_health)
    emit_signal("health_changed", current_health, max_health)

func reset() -> void:
    current_health = max_health
    emit_signal("health_changed", current_health, max_health)
