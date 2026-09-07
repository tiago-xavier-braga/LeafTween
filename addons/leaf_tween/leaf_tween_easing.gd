class_name LeafTweenEasing
extends RefCounted

enum EaseType {
    LINEAR,
    IN_QUAD,
    OUT_QUAD,
    IN_OUT_QUAD,
    IN_CUBIC,
    OUT_CUBIC,
    IN_OUT_CUBIC,
    IN_BOUNCE,
    OUT_BOUNCE
}

static func ease_linear(t: float) -> float:
    return t

static func ease_in_quad(t: float) -> float:
    return t * t

static func ease_out_quad(t: float) -> float:
    return 1 - (1 - t) * (1 - t)

static func ease_in_out_quad(t: float) -> float:
    return 2 * t * t if t < 0.5 else 1 - pow(-2 * t + 2, 2) / 2

static func ease_in_cubic(t: float) -> float:
    return t * t * t

static func ease_out_cubic(t: float) -> float:
    return 1 - pow(1 - t, 3)

static func ease_in_out_cubic(t: float) -> float:
    return 4 * t * t * t if t < 0.5 else 1 - pow(-2 * t + 2, 3) / 2

static func ease_in_bounce(t: float) -> float:
    return 1 - ease_out_bounce(1 - t)

static func ease_out_bounce(t: float) -> float:
    const N1: float = 7.5625
    const D1: float = 2.75

    if t < 1.0 / D1:
        return N1 * t * t
    elif t < 2.0 / D1:
        t -= 1.5 / D1
        return N1 * t * t + 0.75
    elif t < 2.5 / D1:
        t -= 2.25 / D1
        return N1 * t * t + 0.9375
    else:
        t -= 2.625 / D1
        return N1 * t * t + 0.984375

static func apply(easing_type: EaseType, t: float) -> float:
    match easing_type:
        EaseType.LINEAR:
            return ease_linear(t)
        EaseType.IN_QUAD:
            return ease_in_quad(t)
        EaseType.OUT_QUAD:
            return ease_out_quad(t)
        EaseType.IN_OUT_QUAD:
            return ease_in_out_quad(t)
        EaseType.IN_CUBIC:
            return ease_in_cubic(t)
        EaseType.OUT_CUBIC:
            return ease_out_cubic(t)
        EaseType.IN_OUT_CUBIC:
            return ease_in_out_cubic(t)
        EaseType.IN_BOUNCE:
            return ease_in_bounce(t)
        EaseType.OUT_BOUNCE:
            return ease_out_bounce(t)
        _:
            return t