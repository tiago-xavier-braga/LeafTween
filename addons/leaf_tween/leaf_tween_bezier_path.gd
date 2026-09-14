class_name LeafTweenBezierPath extends Resource

@export var point_start: Vector2
@export var control_1: Vector2
@export var control_2: Vector2
@export var point_end: Vector2

func get_point(t: float) -> Vector2:
    var a: Vector2 = lerp(point_start, control_1, t)
    var b: Vector2 = lerp(control_1, control_2, t)
    var c: Vector2 = lerp(control_2, point_end, t)

    var d: Vector2 = lerp(a, b, t)
    var e: Vector2 = lerp(b, c, t)

    return lerp(d, e, t)