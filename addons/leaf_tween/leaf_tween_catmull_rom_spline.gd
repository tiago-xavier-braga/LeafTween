## A Catmull-Rom spline through an ordered list of points, sampled via
## [method get_point]. Pass to [method LeafTween.move_along].
class_name LeafTweenCatmullRomSpline extends Resource

## Control points the spline passes through, in order. Needs at least 2.
@export var points: Array[Vector2] = []

## Returns the position at [param t] along the spline, mapping
## [code][0, 1][/code] across every segment between consecutive
## [member points]. Not clamped here — callers ([LeafTween]'s update loop)
## already clamp to [code][0, 1][/code].
func get_point(t: float) -> Vector2:
    var segment_count: int = points.size() - 1
    var scaled_t: float = clampf(t, 0.0, 1.0) * segment_count
    var segment_index: int = clampi(floori(scaled_t), 0, segment_count - 1)
    var local_t: float = scaled_t - segment_index

    var p0: Vector2 = points[segment_index - 1] if segment_index > 0 else points[segment_index]
    var p1: Vector2 = points[segment_index]
    var p2: Vector2 = points[segment_index + 1]
    var p3: Vector2 = points[segment_index + 2] if segment_index + 2 < points.size() else points[segment_index + 1]

    var t2: float = local_t * local_t
    var t3: float = t2 * local_t

    return 0.5 * (
        (2.0 * p1)
        + (-p0 + p2) * local_t
        + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2
        + (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3
    )
