extends Node

var _tweens: Array[TweenData] = []

class TweenData extends RefCounted:
    var from: Variant
    var to: Variant
    var duration: float
    var elapsed: float = 0.0
    var on_update: Callable = Callable()
    var on_complete: Callable = Callable()

func _process(delta: float) -> void:
    for i in range(_tweens.size() - 1, -1, -1):
        var tween_data: TweenData = _tweens[i]
        tween_data.elapsed += delta
        var t: float = clampf(tween_data.elapsed / tween_data.duration, 0.0, 1.0)
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
