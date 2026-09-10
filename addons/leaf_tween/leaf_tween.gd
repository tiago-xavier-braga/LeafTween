extends Node

const MAX_TWEENS: int = 1024

var _tweens: Array[TweenData] = []

class TweenData extends RefCounted:
    var index: int
    var generation: int = 0
    var active: bool = false
    var paused: bool = false
    var from: Variant
    var to: Variant
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

class TweenHandle extends RefCounted:
    var index: int
    var generation: int


func _ready() -> void:
    for i in range(MAX_TWEENS):
        var tween_data: TweenData = TweenData.new()
        tween_data.index = i
        _tweens.append(tween_data)

func _process(delta: float) -> void:
    for tween_data in _tweens:

        if not tween_data.active:
            continue
        
        if tween_data.paused:
            continue

        tween_data.elapsed += delta

        if tween_data.elapsed < tween_data.delay:
            continue
        
        var t: float = (tween_data.elapsed - tween_data.delay) / tween_data.duration
        t = clampf(t, 0.0, 1.0)
        if tween_data.ease_curve:
            t = tween_data.ease_curve.sample(t)
        else:
            t = LeafTweenEasing.apply(tween_data.ease_type, t)

        var value: Variant = lerp(tween_data.from, tween_data.to, t)
        tween_data.on_update.call(value)

        if t >= 1.0:
            if tween_data.on_complete.is_valid():
                tween_data.on_complete.call()

            _release_tween(tween_data)

func to(from: Variant, to: Variant, duration: float, on_update: Callable) -> TweenData:
    var tween_data: TweenData = _acquire_tween_data()

    tween_data.from = from
    tween_data.to = to
    tween_data.duration = duration
    tween_data.on_update = on_update
    return tween_data

func cancel(handle: TweenHandle) -> void:
    if _is_handle_valid(handle):
        var tween_data: TweenData = _tweens[handle.index]
        _release_tween(tween_data)

func pause(handle: TweenHandle) -> void:
    if _is_handle_valid(handle):
        var tween_data: TweenData = _tweens[handle.index]
        tween_data.paused = true

func resume(handle: TweenHandle) -> void:
    if _is_handle_valid(handle):
        var tween_data: TweenData = _tweens[handle.index]
        tween_data.paused = false

func _is_handle_valid(handle: TweenHandle) -> bool:
    if handle.index < 0 or handle.index >= MAX_TWEENS:
        return false

    var tween_data: TweenData = _tweens[handle.index]
    return tween_data.generation == handle.generation and tween_data.active

func _acquire_tween_data() -> TweenData:
    for tween_data in _tweens:
        if not tween_data.active:
            tween_data.active = true
            return tween_data
    push_error("No available tween data slots. Increase MAX_TWEENS.")
    return null

func _release_tween(tween: TweenData) -> void:
    tween.generation += 1

    tween.active = false
    tween.from = null
    tween.to = null
    tween.duration = 0.0
    tween.elapsed = 0.0
    tween.delay = 0.0
    tween.ease_type = LeafTweenEasing.EaseType.LINEAR
    tween.ease_curve = null
    tween.on_update = Callable()
    tween.on_complete = Callable()

