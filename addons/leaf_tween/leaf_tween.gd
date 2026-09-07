extends Node

var _tweens: Array[TweenData] = []

class TweenData extends RefCounted:
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

func _process(delta: float) -> void:
    for i in range(_tweens.size() - 1, -1, -1):
        var tween_data: TweenData = _tweens[i]
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

            _tweens.remove_at(i)

func to(from: Variant, to: Variant, duration: float, on_update: Callable) -> TweenData:
    var tween_data: TweenData = TweenData.new()
    tween_data.from = from
    tween_data.to = to
    tween_data.duration = duration
    tween_data.on_update = on_update
    _tweens.append(tween_data)
    return tween_data
