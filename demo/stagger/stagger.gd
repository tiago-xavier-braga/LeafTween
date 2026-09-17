extends Control

const DELAY_BETWEEN: float = 0.15
const DURATION: float = 0.4
const MOVE_DISTANCE: float = 700.0

@export var play_button: Button
@export var cancel_button: Button

@export var leaf_tween_box_1: ColorRect
@export var leaf_tween_box_2: ColorRect
@export var leaf_tween_box_3: ColorRect
@export var leaf_tween_box_4: ColorRect
@export var leaf_tween_box_5: ColorRect

@export var native_box_1: ColorRect
@export var native_box_2: ColorRect
@export var native_box_3: ColorRect
@export var native_box_4: ColorRect
@export var native_box_5: ColorRect

var _leaf_tween_boxes: Array[ColorRect]
var _native_boxes: Array[ColorRect]
var _start_x: float
var _active_stagger: Array[TweenData] = []

func _ready() -> void:
	_leaf_tween_boxes = [
		leaf_tween_box_1, leaf_tween_box_2, leaf_tween_box_3, leaf_tween_box_4, leaf_tween_box_5
	]
	_native_boxes = [
		native_box_1, native_box_2, native_box_3, native_box_4, native_box_5
	]
	_start_x = leaf_tween_box_1.position.x

	play_button.pressed.connect(_on_play_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)

func _on_play_pressed() -> void:
	for box in _leaf_tween_boxes:
		box.position.x = _start_x
	for box in _native_boxes:
		box.position.x = _start_x

	_active_stagger = LeafTween.stagger(
		_leaf_tween_boxes, DELAY_BETWEEN,
		func(box: ColorRect) -> TweenData:
			var target: Vector2 = Vector2(_start_x + MOVE_DISTANCE, box.position.y)
			return LeafTween.move(box, target, DURATION).set_ease(LeafTweenEasing.EaseType.OUT_CUBIC)
	)

	for i in range(_native_boxes.size()):
		var box: ColorRect = _native_boxes[i]
		var native_tween: Tween = create_tween()
		native_tween.tween_property(box, "position:x", _start_x + MOVE_DISTANCE, DURATION) \
			.set_delay(i * DELAY_BETWEEN) \
			.set_trans(Tween.TRANS_CUBIC) \
			.set_ease(Tween.EASE_OUT)

func _on_cancel_pressed() -> void:
	for tween_data in _active_stagger:
		LeafTween.cancel(tween_data.get_handle())
	_active_stagger.clear()
