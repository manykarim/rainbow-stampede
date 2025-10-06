extends Node2D
class_name GameManager

@onready var player: Player = $Player
@onready var enemy_spawner: EnemySpawner = $EnemySpawner
@onready var hud_label: Label = $CanvasLayer/HUD/HealthLabel

func _ready() -> void:
    if player and player.health_component:
        player.health_component.health_changed.connect(_on_player_health_changed)
        player.health_component.died.connect(_on_player_died)
        _on_player_health_changed(player.health_component.current_health, player.health_component.max_health)
    if enemy_spawner:
        enemy_spawner.set_target(player)

func _on_player_health_changed(current: int, max_value: int) -> void:
    if hud_label:
        hud_label.text = "HP: %d / %d" % [current, max_value]

func _on_player_died() -> void:
    if hud_label:
        hud_label.text += "\nPress Enter or R to restart"

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.keycode == KEY_R):
        if player and player.health_component and player.health_component.current_health <= 0:
            _restart_run()

func _restart_run() -> void:
    if player:
        player.global_position = Vector2.ZERO
        player.velocity = Vector2.ZERO
        player.health_component.reset()
        player.set_physics_process(true)
        if player.weapon_manager:
            player.weapon_manager.stop_firing()
    if enemy_spawner:
        enemy_spawner.clear_enemies()
