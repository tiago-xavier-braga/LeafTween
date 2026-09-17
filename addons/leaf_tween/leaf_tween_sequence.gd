## Chains multiple [TweenData]s into a series/parallel timeline by
## offsetting each one's delay — no runtime of its own, the tweens already
## play through [LeafTween]'s own update loop the moment they're created.
class_name LeafTweenSequence extends RefCounted

var _tweens: Array[TweenData] = []
var _cursor: float = 0.0
var _last_start: float = 0.0
var _loop_count: int = 1
var _ping_pong: bool = false

## Adds [param tween_data] after every step added so far, running once the
## last one finishes. Returns [code]self[/code] for chaining.
func append(tween_data: TweenData) -> LeafTweenSequence:
	var start_time: float = _cursor + tween_data.delay
	tween_data.delay = start_time
	_last_start = start_time
	_cursor = start_time + tween_data.duration
	_add(tween_data)
	return self

## Adds [param tween_data] running in parallel with the most recently added
## step (whether added via [method append] or [method join]). Returns
## [code]self[/code] for chaining.
func join(tween_data: TweenData) -> LeafTweenSequence:
	var start_time: float = _last_start + tween_data.delay
	tween_data.delay = start_time
	_cursor = maxf(_cursor, start_time + tween_data.duration)
	_add(tween_data)
	return self

## Repeats the whole sequence [param count] times total (pass [code]-1[/code]
## for infinite). Safe to call before, during, or after building the
## sequence with [method append]/[method join].
func set_loop(count: int) -> LeafTweenSequence:
	_loop_count = count
	_apply_loop_settings()
	return self

## When looping (see [method set_loop]), reverses the whole sequence's
## playback order and direction on every other repetition.
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
