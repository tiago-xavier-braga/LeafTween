extends Node

const MAX_TWEENS: int = 1024

var _tweens: Array[TweenData] = []

class TweenData extends RefCounted:
    var active: bool = false
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

func _ready() -> void:
    for i in range(MAX_TWEENS):
        _tweens.append(TweenData.new())

func _process(delta: float) -> void:
    for tween_data in _tweens:

        if not tween_data.active:
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

func _acquire_tween_data() -> TweenData:
    for tween_data in _tweens:
        if not tween_data.active:
            tween_data.active = true
            return tween_data
    push_error("No available tween data slots. Increase MAX_TWEENS.")
    return null

func _release_tween(tween: TweenData) -> void:
    tween.active = false
    tween.elapsed = 0.0
    tween.delay = 0.0
    tween.ease_type = LeafTweenEasing.EaseType.LINEAR
    tween.ease_curve = null
    tween.on_update = Callable()
    tween.on_complete = Callable()

