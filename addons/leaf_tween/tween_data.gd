class_name TweenData extends RefCounted

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
var ease_type: LeafTweenEasing.EaseType = LeafTweenEasing.EaseType.LINEAR
var ease_curve: Curve = null
var on_update: Callable = Callable()
var on_complete: Callable = Callable()

func set_ease(ease_type: LeafTweenEasing.EaseType) -> TweenData:
	self.ease_type = ease_type
	return self

func set_ease_curve(curve: Curve) -> TweenData:
	self.ease_curve = curve
	return self

func set_delay(delay: float) -> TweenData:
	self.delay = delay
	return self

func set_on_update(callback: Callable) -> TweenData:
	self.on_update = callback
	return self

func set_on_complete(callback: Callable) -> TweenData:
	self.on_complete = callback
	return self

func get_handle() -> TweenHandle:
	var handle: TweenHandle = TweenHandle.new()
	handle.index = self.index
	handle.generation = self.generation
	return handle
