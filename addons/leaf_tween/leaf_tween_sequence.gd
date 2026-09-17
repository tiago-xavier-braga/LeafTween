class_name LeafTweenSequence extends RefCounted

var _tweens: Array[TweenData] = []
var _cursor: float = 0.0
var _last_start: float = 0.0
var _loop_count: int = 1
var _ping_pong: bool = false

func append(tween_data: TweenData) -> LeafTweenSequence:
	var start_time: float = _cursor + tween_data.delay
	tween_data.delay = start_time
	_last_start = start_time
	_cursor = start_time + tween_data.duration
	_add(tween_data)
	return self

func join(tween_data: TweenData) -> LeafTweenSequence:
	var start_time: float = _last_start + tween_data.delay
	tween_data.delay = start_time
	_cursor = maxf(_cursor, start_time + tween_data.duration)
	_add(tween_data)
	return self

func set_loop(count: int) -> LeafTweenSequence:
	_loop_count = count
	_apply_loop_settings()
	return self

func set_ping_pong(enabled: bool = true) -> LeafTweenSequence:
	_ping_pong = enabled
	_apply_loop_settings()
	return self

func _add(tween_data: TweenData) -> void:
	_tweens.append(tween_data)
	_apply_loop_settings()

func _apply_loop_settings() -> void:
	for tween_data in _tweens:
		tween_data.loop_duration = _cursor
		tween_data.set_loop(_loop_count).set_ping_pong(_ping_pong)
