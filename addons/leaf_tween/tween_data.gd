## Configuration and runtime state for one active tween. Returned by
## [LeafTween]'s builder methods ([method LeafTween.to],
## [method LeafTween.move], [method LeafTween.move_along], ...) — configure
## it by chaining the [code]set_*[/code] methods below, each returning
## [code]self[/code].
class_name TweenData extends RefCounted

## Which interpolation [LeafTween]'s update loop applies each frame — set
## internally by [method LeafTween.to]/[method LeafTween.move_along], not
## meant to be set directly.
enum TweenAction {
    LERP,
    PATH,
}

var index: int
var generation: int = 0
var active: bool = false
var paused: bool = false
var from: Variant
var to: Variant
var path: Resource
var action: TweenAction = TweenAction.LERP
var duration: float
var elapsed: float = 0.0
var delay: float = 0.0
var loop_count: int = 1
var loop_duration: float = 0.0
var ping_pong: bool = false
var ease_type: LeafTweenEasing.EaseType = LeafTweenEasing.EaseType.LINEAR
var ease_curve: Curve = null
var on_update: Callable = Callable()
var on_complete: Callable = Callable()

## Sets the easing curve from [enum LeafTweenEasing.EaseType]. Ignored if
## [method set_ease_curve] has also been called — the [Curve] always wins.
func set_ease(ease_type: LeafTweenEasing.EaseType) -> TweenData:
	self.ease_type = ease_type
	return self

## Sets a custom [Curve] resource as the easing source, sampled once per
## frame — takes priority over [method set_ease] if both are set. Lets an
## ease be tuned visually in the inspector instead of picking from
## [enum LeafTweenEasing.EaseType].
func set_ease_curve(curve: Curve) -> TweenData:
	self.ease_curve = curve
	return self

## Delays the tween's start by [param delay] seconds. Elapsed time still
## accumulates from the moment the tween was created; it just doesn't start
## interpolating until [param delay] has passed.
func set_delay(delay: float) -> TweenData:
	self.delay = delay
	return self

## Repeats the tween [param count] times total (pass [code]-1[/code] for
## infinite). The callback set via [method set_on_complete] only fires once,
## after the last repetition finishes — not once per loop.
func set_loop(count: int) -> TweenData:
	self.loop_count = count
	return self

## When looping (see [method set_loop]), reverses direction on every other
## repetition instead of restarting from the beginning each time.
func set_ping_pong(enabled: bool = true) -> TweenData:
	self.ping_pong = enabled
	return self

## Overrides the update callback originally passed to [method LeafTween.to].
## Rarely needed directly — the node helpers ([method LeafTween.move], etc.)
## already set this for you.
func set_on_update(callback: Callable) -> TweenData:
	self.on_update = callback
	return self

## Sets a callback invoked once, when the tween finishes (after any looping
## configured with [method set_loop]).
func set_on_complete(callback: Callable) -> TweenData:
	self.on_complete = callback
	return self

## Returns a lightweight [TweenHandle] ([code]{index, generation}[/code])
## for [method LeafTween.cancel], [method LeafTween.pause], and
## [method LeafTween.resume] — safe to store even after this tween's pool
## slot is later reused, since a stale handle is detected and ignored.
func get_handle() -> TweenHandle:
	var handle: TweenHandle = TweenHandle.new()
	handle.index = self.index
	handle.generation = self.generation
	return handle
