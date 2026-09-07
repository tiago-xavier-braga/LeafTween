extends Control

@export var duration: float = 1.5
@export var final_position: float = 1600.0

@export var leaf_tween_box: ColorRect
@export var native_tween_box: ColorRect
@export var leaf_tween_curve_box: ColorRect
@export var manual_curve_box: ColorRect

@export var color_finish: Color = Color.WHITE

func _ready() -> void:
	var _handle: LeafTween.TweenData = LeafTween.to(
		leaf_tween_box.position.x,
		final_position,
		duration,
		func(value: float) -> void:
			leaf_tween_box.position.x = value
	).set_ease(LeafTweenEasing.EaseType.OUT_BOUNCE).set_on_complete(_change_color.bind(leaf_tween_box))

	var native_tween: Tween = create_tween()
	native_tween.tween_property(native_tween_box, "position:x", final_position, duration) \
		.set_trans(Tween.TRANS_BOUNCE) \
		.set_ease(Tween.EASE_OUT)
	native_tween.finished.connect(func() -> void:
		_change_color(native_tween_box)
	)

	var custom_curve := Curve.new()
	custom_curve.add_point(Vector2(0.0, 0.0))
	custom_curve.add_point(Vector2(0.7, 1.15))
	custom_curve.add_point(Vector2(1.0, 1.0))

	var _curve_handle: LeafTween.TweenData = LeafTween.to(
		leaf_tween_curve_box.position.x,
		final_position,
		duration,
		func(value: float) -> void:
			leaf_tween_curve_box.position.x = value
	).set_ease_curve(custom_curve).set_on_complete(_change_color.bind(leaf_tween_curve_box))

	var manual_start_x: float = manual_curve_box.position.x
	var manual_tween: Tween = create_tween()
	manual_tween.tween_method(
		func(t: float) -> void:
			manual_curve_box.position.x = lerp(manual_start_x, final_position, custom_curve.sample(t)),
		0.0, 1.0, duration
	)
	manual_tween.finished.connect(func() -> void:
		_change_color(manual_curve_box)
	)

func _change_color(box: ColorRect) -> void: box.modulate = color_finish