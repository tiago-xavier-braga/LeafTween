extends Control

const STEP_DURATION: float = 0.7
const LOOP_COUNT: int = 2
const MOVE_DISTANCE: float = 480.0

@export var play_button: Button
@export var series_box_1: ColorRect
@export var series_box_2: ColorRect
@export var series_box_3: ColorRect
@export var parallel_box: ColorRect

var _series_1_start_x: float
var _series_2_start_x: float
var _series_3_start_x: float
var _parallel_start_y: float

func _ready() -> void:
	_series_1_start_x = series_box_1.position.x
	_series_2_start_x = series_box_2.position.x
	_series_3_start_x = series_box_3.position.x
	_parallel_start_y = parallel_box.position.y

	play_button.pressed.connect(_on_play_pressed)

func _on_play_pressed() -> void:
	play_button.disabled = true

	series_box_1.position.x = _series_1_start_x
	series_box_2.position.x = _series_2_start_x
	series_box_3.position.x = _series_3_start_x
	parallel_box.position.y = _parallel_start_y

	var step_1: TweenData = LeafTween.to(
		_series_1_start_x, _series_1_start_x + MOVE_DISTANCE, STEP_DURATION,
		func(value: float) -> void: series_box_1.position.x = value
	).set_ease(LeafTweenEasing.EaseType.IN_OUT_QUAD)

	var step_2: TweenData = LeafTween.to(
		_series_2_start_x, _series_2_start_x + MOVE_DISTANCE, STEP_DURATION,
		func(value: float) -> void: series_box_2.position.x = value
	).set_ease(LeafTweenEasing.EaseType.IN_OUT_QUAD)

	var step_3: TweenData = LeafTween.to(
		_series_3_start_x, _series_3_start_x + MOVE_DISTANCE, STEP_DURATION,
		func(value: float) -> void: series_box_3.position.x = value
	).set_ease(LeafTweenEasing.EaseType.IN_OUT_QUAD)

	var parallel_step: TweenData = LeafTween.to(
		_parallel_start_y, _parallel_start_y - MOVE_DISTANCE, STEP_DURATION,
		func(value: float) -> void: parallel_box.position.y = value
	).set_ease(LeafTweenEasing.EaseType.IN_OUT_QUAD)

	var sequence: LeafTweenSequence = LeafTweenSequence.new()
	sequence.append(step_1)
	sequence.append(step_2)
	sequence.join(parallel_step)
	sequence.append(step_3)
	sequence.set_loop(LOOP_COUNT)

	step_3.set_on_complete(func() -> void: play_button.disabled = false)
