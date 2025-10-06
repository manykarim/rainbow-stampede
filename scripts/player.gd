extends CharacterBody2D
class_name Player

@export var move_speed: float = 180.0
@export var acceleration: float = 10.0

@onready var weapon_manager: WeaponManager = $WeaponManager
@onready var health_component: HealthComponent = $HealthComponent

func _ready() -> void:
    _ensure_input_actions()
    if health_component:
        health_component.died.connect(_on_player_died)
    set_process_input(true)

func _physics_process(delta: float) -> void:
    var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var target_velocity := input_vector.normalized() * move_speed
    velocity = velocity.lerp(target_velocity, clamp(delta * acceleration, 0.0, 1.0))
    move_and_slide()
    if weapon_manager:
        var aim_dir := (get_global_mouse_position() - global_position).normalized()
        if aim_dir.length() == 0:
            aim_dir = Vector2.UP
        weapon_manager.update_weapon(delta, aim_dir)

func apply_hit(damage: int) -> void:
    if health_component:
        health_component.apply_damage(damage)

func _on_player_died() -> void:
    set_physics_process(false)
    if weapon_manager:
        weapon_manager.stop_firing()

func _ensure_input_actions() -> void:
    _ensure_action("move_up", KEY_W, KEY_UP)
    _ensure_action("move_down", KEY_S, KEY_DOWN)
    _ensure_action("move_left", KEY_A, KEY_LEFT)
    _ensure_action("move_right", KEY_D, KEY_RIGHT)
    if not InputMap.has_action("fire"):
        InputMap.add_action("fire")
        var mouse := InputEventMouseButton.new()
        mouse.button_index = MouseButton.LEFT
        InputMap.action_add_event("fire", mouse)

func _ensure_action(name: StringName, primary_key: int, secondary_key: int) -> void:
    if InputMap.has_action(name):
        return
    InputMap.add_action(name)
    var event_primary := InputEventKey.new()
    event_primary.physical_keycode = primary_key
    event_primary.keycode = primary_key
    InputMap.action_add_event(name, event_primary)
    var event_secondary := InputEventKey.new()
    event_secondary.physical_keycode = secondary_key
    event_secondary.keycode = secondary_key
    InputMap.action_add_event(name, event_secondary)
