## Autoload singleton driving every active tween from a single pooled
## update loop. Configure a tween through the [TweenData] a builder method
## below returns, then let it run — no per-tween node, no manual [Tween] wiring.
extends Node

## Fixed pool size — the maximum number of tweens that can run at once.
## Acquiring past this logs an error and returns [code]null[/code].
const MAX_TWEENS: int = 1024

var _tweens: Array[TweenData] = []

var _highest_active_index: int = -1

func _ready() -> void:
	for i in range(MAX_TWEENS):
		var tween_data: TweenData = TweenData.new()
		tween_data.index = i
		_tweens.append(tween_data)

func _process(delta: float) -> void:
	for i in range(_highest_active_index + 1): 
		var tween_data: TweenData = _tweens[i]

		if not tween_data.active:
			continue
		
		if tween_data.paused:
			continue

		tween_data.elapsed += delta

		var cycle: Dictionary = _resolve_cycle_position(tween_data)
		var position: float = cycle.position
		var finished: bool = cycle.finished

		if position < 0.0:
			continue

		var t: float = clampf(position / tween_data.duration, 0.0, 1.0)
		if tween_data.ease_curve:
			t = tween_data.ease_curve.sample(t)
		else:
			t = LeafTweenEasing.apply(tween_data.ease_type, t)

		var value: Variant
		match tween_data.action:
			TweenData.TweenAction.LERP:
				value = lerp(tween_data.from, tween_data.to, t)
			TweenData.TweenAction.PATH:
				value = tween_data.path.get_point(t)

		tween_data.on_update.call(value)

		if finished:
			var on_complete: Callable = tween_data.on_complete
			_release_tween(tween_data)

			if on_complete.is_valid():
				on_complete.call()

## Animates any interpolatable [Variant] ([float], [Vector2], [Vector3],
## [Color], ...) from [param from] to [param to] over [param duration]
## seconds, calling [param on_update] with the current value each frame.
## The generic primitive every other helper below is built on.
func to(from: Variant, to: Variant, duration: float, on_update: Callable) -> TweenData:
	var tween_data: TweenData = _acquire_tween_data()

	tween_data.from = from
	tween_data.to = to
	tween_data.duration = duration
	tween_data.on_update = on_update
	return tween_data

## Moves [param node] along [param path] (a [LeafTweenBezierPath] or
## [LeafTweenCatmullRomSpline], or any [Resource] exposing
## [code]get_point(t: float) -> Vector2[/code]) over [param duration] seconds.
func move_along(node: Node2D, path: Resource, duration: float) -> TweenData:
	var tween_data: TweenData = _acquire_tween_data()

	tween_data.path = path
	tween_data.duration = duration
	tween_data.action = TweenData.TweenAction.PATH
	tween_data.on_update = Callable(node, "set_position")
	return tween_data

## Animates [param node]'s [code]position[/code] to [param target] over
## [param duration] seconds. Works for both [Node2D] and [Control].
func move(node: Node, target: Vector2, duration: float) -> TweenData:
	return to(node.position, target, duration, Callable(node, "set_position"))

## Animates a [Control]'s [code]size[/code] to [param target_size] over
## [param duration] seconds.
func resize(control: Control, target_size: Vector2, duration: float) -> TweenData:
	return to(control.size, target_size, duration, Callable(control, "set_size"))

## Animates a [CanvasItem]'s [code]modulate[/code] alpha to
## [param target_alpha] over [param duration] seconds, leaving its RGB
## untouched.
func fade(canvas_item: CanvasItem, target_alpha: float, duration: float) -> TweenData:
	var start_color: Color = canvas_item.modulate
	var target_color: Color = Color(start_color.r, start_color.g, start_color.b, target_alpha)
	return to(start_color, target_color, duration, Callable(canvas_item, "set_modulate"))

## Animates a [CanvasItem]'s full [code]modulate[/code] color to
## [param target_color] over [param duration] seconds.
func modulate(canvas_item: CanvasItem, target_color: Color, duration: float) -> TweenData:
	return to(canvas_item.modulate, target_color, duration, Callable(canvas_item, "set_modulate"))

## Calls [param tween_factory] once per entry in [param nodes], offsetting
## each resulting [TweenData]'s delay by its index times
## [param delay_between]. [param tween_factory] takes a node and returns any
## tween built from it, e.g.
## [code]func(n): return LeafTween.move(n, target, duration)[/code].
## Cancelling mid-stagger works for free: cancel one entry's own handle
## (from [method TweenData.get_handle]) without touching the rest.
func stagger(nodes: Array, delay_between: float, tween_factory: Callable) -> Array[TweenData]:
	var tweens: Array[TweenData] = []
	for i in range(nodes.size()):
		var tween_data: TweenData = tween_factory.call(nodes[i])
		tween_data.delay += float(i) * delay_between
		tweens.append(tween_data)
	return tweens

## Stops the tween [param handle] refers to and frees its pool slot. A stale
## or already-inactive handle is silently ignored.
func cancel(handle: TweenHandle) -> void:
	if _is_handle_valid(handle):
		var tween_data: TweenData = _tweens[handle.index]
		_release_tween(tween_data)

## Freezes the tween [param handle] refers to in place; its elapsed time
## stops advancing until [method resume] is called.
func pause(handle: TweenHandle) -> void:
	if _is_handle_valid(handle):
		var tween_data: TweenData = _tweens[handle.index]
		tween_data.paused = true

## Unfreezes a tween previously stopped with [method pause].
func resume(handle: TweenHandle) -> void:
	if _is_handle_valid(handle):
		var tween_data: TweenData = _tweens[handle.index]
		tween_data.paused = false

func _is_handle_valid(handle: TweenHandle) -> bool:
	if handle.index < 0 or handle.index >= MAX_TWEENS:
		return false
	var tween_data: TweenData = _tweens[handle.index]
	return tween_data.generation == handle.generation and tween_data.active

func _resolve_cycle_position(tween_data: TweenData) -> Dictionary:
	var cycle_duration: float = tween_data.loop_duration if tween_data.loop_duration > 0.0 else tween_data.delay + tween_data.duration
	var infinite: bool = tween_data.loop_count < 0
	var total_duration: float = INF if infinite else cycle_duration * tween_data.loop_count

	var finished: bool = not infinite and tween_data.elapsed >= total_duration
	var clamped_elapsed: float = tween_data.elapsed if infinite else minf(tween_data.elapsed, total_duration)

	var iteration: int = (tween_data.loop_count - 1) if finished else int(clamped_elapsed / cycle_duration)
	var position_in_cycle: float = cycle_duration if finished else clamped_elapsed - float(iteration) * cycle_duration

	if tween_data.ping_pong and iteration % 2 == 1:
		position_in_cycle = cycle_duration - position_in_cycle

	return {
		"position": position_in_cycle - tween_data.delay,
		"finished": finished,
	}

func _acquire_tween_data() -> TweenData:
	for i in range(_tweens.size()):
		var tween_data: TweenData = _tweens[i]
		if not tween_data.active:
			tween_data.active = true
			if tween_data.index > _highest_active_index:
				_highest_active_index = tween_data.index
			return tween_data

	push_error("No available tween data slots. Increase MAX_TWEENS.")
	return null

func _release_tween(tween: TweenData) -> void:
	tween.generation += 1

	tween.active = false
	tween.from = null
	tween.to = null
	tween.path = null
	tween.action = TweenData.TweenAction.LERP
	tween.duration = 0.0
	tween.elapsed = 0.0
	tween.delay = 0.0
	tween.loop_count = 1
	tween.loop_duration = 0.0
	tween.ping_pong = false
	tween.ease_type = LeafTweenEasing.EaseType.LINEAR
	tween.ease_curve = null
	tween.on_update = Callable()
	tween.on_complete = Callable()

	if tween.index == _highest_active_index:
		for i in range(_highest_active_index - 1, -1, -1):
			if _tweens[i].active:
				_highest_active_index = i
				return
		_highest_active_index = -1
