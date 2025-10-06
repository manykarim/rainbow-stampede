extends Node
class_name ObjectPool

@export var scene: PackedScene
@export var initial_size: int = 8

var _available: Array[Node] = []
var _in_use: Array[Node] = []

func _ready() -> void:
    if scene == null:
        push_warning("ObjectPool requires a PackedScene assigned to 'scene'.")
        return
    for i in initial_size:
        var instance := scene.instantiate()
        if instance is CanvasItem:
            instance.visible = false
        _available.append(instance)
        add_child(instance)
        _set_processing(instance, false)

func take() -> Node:
    if scene == null:
        return null
    var instance: Node
    if _available.is_empty():
        instance = scene.instantiate()
        add_child(instance)
    else:
        instance = _available.pop_back()
    _in_use.append(instance)
    if instance is CanvasItem:
        instance.visible = true
    _set_processing(instance, true)
    return instance

func recycle(instance: Node) -> void:
    if instance == null:
        return
    if instance in _in_use:
        _in_use.erase(instance)
        if instance is Node2D:
            instance.position = Vector2.ZERO
            instance.rotation = 0.0
        if instance is CanvasItem:
            instance.visible = false
        _set_processing(instance, false)
        _available.append(instance)

func recycle_all() -> void:
    for node in _in_use.duplicate():
        recycle(node)

func get_active_count() -> int:
    return _in_use.size()

func _set_processing(node: Node, enabled: bool) -> void:
    if node.has_method("set_process"):
        node.set_process(enabled)
    if node.has_method("set_physics_process"):
        node.set_physics_process(enabled)
    if node.has_method("set_process_input"):
        node.set_process_input(enabled)
