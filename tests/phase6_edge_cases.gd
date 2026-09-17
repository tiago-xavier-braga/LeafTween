extends Node

var _pass_count: int = 0
var _fail_count: int = 0

func _ready() -> void:
	await _test_cancel_stops_update()
	_test_stale_handle_after_reuse()
	await _test_pause_resume()
	await _test_stagger_partial_cancel()

	print("")
	print("%d passed, %d failed" % [_pass_count, _fail_count])
	get_tree().quit(0 if _fail_count == 0 else 1)

func _expect(condition: bool, description: String) -> void:
	if condition:
		_pass_count += 1
		print("PASS - ", description)
	else:
		_fail_count += 1
		print("FAIL - ", description)

func _test_cancel_stops_update() -> void:
	var completed: Array = [false]
	var tween_data: TweenData = LeafTween.to(0.0, 1.0, 0.1, func(_v: float) -> void: pass).set_on_complete(
		func() -> void: completed[0] = true
	)

	LeafTween.cancel(tween_data.get_handle())

	await get_tree().create_timer(0.2).timeout

	_expect(not completed[0], "cancel() before completion: on_complete never fires")

func _test_stale_handle_after_reuse() -> void:
	var tween_a: TweenData = LeafTween.to(0.0, 1.0, 0.1, func(_v: float) -> void: pass)
	var stale_handle: TweenHandle = tween_a.get_handle()
	LeafTween.cancel(stale_handle)

	var tween_b: TweenData = LeafTween.to(0.0, 1.0, 0.3, func(_v: float) -> void: pass)

	LeafTween.pause(stale_handle)

	_expect(not tween_b.paused, "pause() through a stale handle does not reach the slot's new occupant")

	LeafTween.cancel(tween_b.get_handle())

func _test_pause_resume() -> void:
	var last_value: Array = [-1.0]
	var tween_data: TweenData = LeafTween.to(0.0, 1.0, 0.3, func(v: float) -> void: last_value[0] = v)
	var handle: TweenHandle = tween_data.get_handle()

	await get_tree().create_timer(0.1).timeout
	LeafTween.pause(handle)
	var value_at_pause: float = last_value[0]

	await get_tree().create_timer(0.2).timeout
	_expect(is_equal_approx(last_value[0], value_at_pause), "pause() freezes the tween's value")

	LeafTween.resume(handle)
	await get_tree().create_timer(0.3).timeout
	_expect(is_equal_approx(last_value[0], 1.0), "resume() lets a paused tween reach completion")

func _test_stagger_partial_cancel() -> void:
	var nodes: Array[Node2D] = [Node2D.new(), Node2D.new(), Node2D.new()]
	var tweens: Array[TweenData] = LeafTween.stagger(
		nodes, 0.2,
		func(n: Node2D) -> TweenData: return LeafTween.move(n, Vector2(10.0, 0.0), 0.1)
	)

	LeafTween.cancel(tweens[1].get_handle())
	LeafTween.cancel(tweens[2].get_handle())

	await get_tree().create_timer(0.6).timeout

	_expect(is_equal_approx(nodes[0].position.x, 10.0), "stagger: uncancelled entry still completes")
	_expect(is_equal_approx(nodes[1].position.x, 0.0), "stagger: cancelling a mid-flight entry freezes it")
	_expect(is_equal_approx(nodes[2].position.x, 0.0), "stagger: cancelling a not-yet-started entry keeps it from starting")
