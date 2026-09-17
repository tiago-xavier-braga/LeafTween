extends Node2D

const PATH_SAMPLE_COUNT: int = 32

@export var duration: float = 3.0

@export var bezier_points: Array[Vector2] = [
	Vector2(0.0, 0.0),
	Vector2(150.0, -300.0),
	Vector2(450.0, 300.0),
	Vector2(600.0, 0.0),
]

@export var spline_points: Array[Vector2] = [
	Vector2(0.0, 200.0),
	Vector2(200.0, -100.0),
	Vector2(400.0, 250.0),
	Vector2(600.0, -150.0),
	Vector2(800.0, 200.0),
]

@export var bezier_marker: Sprite2D
@export var spline_marker: Sprite2D
@export var bezier_line: Line2D
@export var spline_line: Line2D
@export var native_line: Line2D
@export var native_path: Path2D
@export var native_follow: PathFollow2D

func _ready() -> void:
	var bezier_path: LeafTweenBezierPath = LeafTweenBezierPath.new()
	bezier_path.point_start = bezier_points[0]
	bezier_path.control_1 = bezier_points[1]
	bezier_path.control_2 = bezier_points[2]
	bezier_path.point_end = bezier_points[3]

	var spline: LeafTweenCatmullRomSpline = LeafTweenCatmullRomSpline.new()
	spline.points = spline_points

	_draw_path(bezier_line, bezier_path)
	_draw_path(spline_line, spline)
	_draw_path(native_line, bezier_path)

	LeafTween.move_along(bezier_marker, bezier_path, duration).set_ease(LeafTweenEasing.EaseType.IN_OUT_QUAD)
	LeafTween.move_along(spline_marker, spline, duration).set_ease(LeafTweenEasing.EaseType.IN_OUT_QUAD)

	var native_curve: Curve2D = Curve2D.new()
	native_curve.add_point(bezier_points[0], Vector2.ZERO, bezier_points[1] - bezier_points[0])
	native_curve.add_point(bezier_points[3], bezier_points[2] - bezier_points[3], Vector2.ZERO)
	native_path.curve = native_curve

	var native_tween: Tween = create_tween()
	native_tween.tween_property(native_follow, "progress_ratio", 1.0, duration) \
		.set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_IN_OUT)

func _draw_path(line: Line2D, path: Variant) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(PATH_SAMPLE_COUNT + 1):
		var t: float = float(i) / float(PATH_SAMPLE_COUNT)
		points.append(path.get_point(t))
	line.points = points
