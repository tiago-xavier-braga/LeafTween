## A cubic Bezier curve (4 control points), sampled via [method get_point].
## Pass to [method LeafTween.move_along].
class_name LeafTweenBezierPath extends Resource

## Curve start point.
@export var point_start: Vector2
## First control point (pulls the curve near the start).
@export var control_1: Vector2
## Second control point (pulls the curve near the end).
@export var control_2: Vector2
## Curve end point.
@export var point_end: Vector2

## Returns the position at [param t] along the curve, where [code]0.0[/code]
## is [member point_start] and [code]1.0[/code] is [member point_end]. Not
## clamped here — callers ([LeafTween]'s update loop) already clamp to
## [code][0, 1][/code].
func get_point(t: float) -> Vector2:
    var a: Vector2 = lerp(point_start, control_1, t)
    var b: Vector2 = lerp(control_1, control_2, t)
    var c: Vector2 = lerp(control_2, point_end, t)

    var d: Vector2 = lerp(a, b, t)
    var e: Vector2 = lerp(b, c, t)

    return lerp(d, e, t)