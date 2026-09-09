class_name LeafTweenEasing
extends RefCounted

enum EaseType {
	LINEAR,
	IN_SINE,
	OUT_SINE,
	IN_OUT_SINE,
	IN_QUAD,
	OUT_QUAD,
	IN_OUT_QUAD,
	IN_CUBIC,
	OUT_CUBIC,
	IN_OUT_CUBIC,
	IN_QUART,
	OUT_QUART,
	IN_OUT_QUART,
	IN_QUINT,
	OUT_QUINT,
	IN_OUT_QUINT,
	IN_EXPO,
	OUT_EXPO,
	IN_OUT_EXPO,
	IN_CIRC,
	OUT_CIRC,
	IN_OUT_CIRC,
	IN_BACK,
	OUT_BACK,
	IN_OUT_BACK,
	IN_ELASTIC,
	OUT_ELASTIC,
	IN_OUT_ELASTIC,
	IN_BOUNCE,
	OUT_BOUNCE,
	IN_OUT_BOUNCE
}

static func ease_linear(t: float) -> float:
	return t

static func ease_in_sine(t: float) -> float:
	return 1.0 - cos(t * PI / 2.0)

static func ease_out_sine(t: float) -> float:
	return sin(t * PI / 2.0)

static func ease_in_out_sine(t: float) -> float:
	return -(cos(PI * t) - 1.0) / 2.0

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

static func ease_in_quart(t: float) -> float:
	return t * t * t * t

static func ease_out_quart(t: float) -> float:
	return 1.0 - pow(1.0 - t, 4)

static func ease_in_out_quart(t: float) -> float:
	return 8.0 * t * t * t * t if t < 0.5 else 1.0 - pow(-2.0 * t + 2.0, 4) / 2.0

static func ease_in_quint(t: float) -> float:
	return t * t * t * t * t

static func ease_out_quint(t: float) -> float:
	return 1.0 - pow(1.0 - t, 5)

static func ease_in_out_quint(t: float) -> float:
	return 16.0 * t * t * t * t * t if t < 0.5 else 1.0 - pow(-2.0 * t + 2.0, 5) / 2.0

static func ease_in_expo(t: float) -> float:
	return 0.0 if t == 0.0 else pow(2.0, 10.0 * t - 10.0)

static func ease_out_expo(t: float) -> float:
	return 1.0 if t == 1.0 else 1.0 - pow(2.0, -10.0 * t)

static func ease_in_out_expo(t: float) -> float:
	if t == 0.0:
		return 0.0
	if t == 1.0:
		return 1.0
	return pow(2.0, 20.0 * t - 10.0) / 2.0 if t < 0.5 else (2.0 - pow(2.0, -20.0 * t + 10.0)) / 2.0

static func ease_in_circ(t: float) -> float:
	return 1.0 - sqrt(1.0 - pow(t, 2))

static func ease_out_circ(t: float) -> float:
	return sqrt(1.0 - pow(t - 1.0, 2))

static func ease_in_out_circ(t: float) -> float:
	if t < 0.5:
		return (1.0 - sqrt(1.0 - pow(2.0 * t, 2))) / 2.0
	return (sqrt(1.0 - pow(-2.0 * t + 2.0, 2)) + 1.0) / 2.0

static func ease_in_back(t: float) -> float:
	const OVERSHOOT: float = 1.70158
	const OVERSHOOT_CUBIC: float = OVERSHOOT + 1.0
	return OVERSHOOT_CUBIC * t * t * t - OVERSHOOT * t * t

static func ease_out_back(t: float) -> float:
	const OVERSHOOT: float = 1.70158
	const OVERSHOOT_CUBIC: float = OVERSHOOT + 1.0
	return 1.0 + OVERSHOOT_CUBIC * pow(t - 1.0, 3) + OVERSHOOT * pow(t - 1.0, 2)

static func ease_in_out_back(t: float) -> float:
	const OVERSHOOT: float = 1.70158
	const OVERSHOOT_INOUT: float = OVERSHOOT * 1.525
	if t < 0.5:
		return (pow(2.0 * t, 2) * ((OVERSHOOT_INOUT + 1.0) * 2.0 * t - OVERSHOOT_INOUT)) / 2.0
	return (pow(2.0 * t - 2.0, 2) * ((OVERSHOOT_INOUT + 1.0) * (2.0 * t - 2.0) + OVERSHOOT_INOUT) + 2.0) / 2.0

static func ease_in_elastic(t: float) -> float:
	const PERIOD: float = 2.0 * PI / 3.0

	if t == 0.0:
		return 0.0
	if t == 1.0:
		return 1.0
	return -pow(2.0, 10.0 * t - 10.0) * sin((t * 10.0 - 10.75) * PERIOD)

static func ease_out_elastic(t: float) -> float:
	const PERIOD: float = 2.0 * PI / 3.0

	if t == 0.0:
		return 0.0
	if t == 1.0:
		return 1.0
	return pow(2.0, -10.0 * t) * sin((t * 10.0 - 0.75) * PERIOD) + 1.0

static func ease_in_out_elastic(t: float) -> float:
	const PERIOD: float = 2.0 * PI / 4.5

	if t == 0.0:
		return 0.0
	if t == 1.0:
		return 1.0
	if t < 0.5:
		return -(pow(2.0, 20.0 * t - 10.0) * sin((20.0 * t - 11.125) * PERIOD)) / 2.0
	return (pow(2.0, -20.0 * t + 10.0) * sin((20.0 * t - 11.125) * PERIOD)) / 2.0 + 1.0

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

static func ease_in_out_bounce(t: float) -> float:
	if t < 0.5:
		return (1.0 - ease_out_bounce(1.0 - 2.0 * t)) / 2.0
	return (1.0 + ease_out_bounce(2.0 * t - 1.0)) / 2.0

static func apply(easing_type: EaseType, t: float) -> float:
	match easing_type:
		EaseType.LINEAR:
			return ease_linear(t)
		EaseType.IN_SINE:
			return ease_in_sine(t)
		EaseType.OUT_SINE:
			return ease_out_sine(t)
		EaseType.IN_OUT_SINE:
			return ease_in_out_sine(t)
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
		EaseType.IN_QUART:
			return ease_in_quart(t)
		EaseType.OUT_QUART:
			return ease_out_quart(t)
		EaseType.IN_OUT_QUART:
			return ease_in_out_quart(t)
		EaseType.IN_QUINT:
			return ease_in_quint(t)
		EaseType.OUT_QUINT:
			return ease_out_quint(t)
		EaseType.IN_OUT_QUINT:
			return ease_in_out_quint(t)
		EaseType.IN_EXPO:
			return ease_in_expo(t)
		EaseType.OUT_EXPO:
			return ease_out_expo(t)
		EaseType.IN_OUT_EXPO:
			return ease_in_out_expo(t)
		EaseType.IN_CIRC:
			return ease_in_circ(t)
		EaseType.OUT_CIRC:
			return ease_out_circ(t)
		EaseType.IN_OUT_CIRC:
			return ease_in_out_circ(t)
		EaseType.IN_BACK:
			return ease_in_back(t)
		EaseType.OUT_BACK:
			return ease_out_back(t)
		EaseType.IN_OUT_BACK:
			return ease_in_out_back(t)
		EaseType.IN_ELASTIC:
			return ease_in_elastic(t)
		EaseType.OUT_ELASTIC:
			return ease_out_elastic(t)
		EaseType.IN_OUT_ELASTIC:
			return ease_in_out_elastic(t)
		EaseType.IN_BOUNCE:
			return ease_in_bounce(t)
		EaseType.OUT_BOUNCE:
			return ease_out_bounce(t)
		EaseType.IN_OUT_BOUNCE:
			return ease_in_out_bounce(t)
		_:
			return t
