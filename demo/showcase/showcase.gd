extends Control

const BAR_COUNT: int = 20
const BAR_WIDTH: float = 56.0
const BAR_GAP: float = 20.0
const MIN_HEIGHT: float = 40.0
const MAX_HEIGHT: float = 520.0
const BASELINE_Y: float = 760.0
const STAGGER_DELAY: float = 0.05
const DURATION: float = 0.7
const COLOR_START: Color = Color(0.5803922, 0.8235294, 0.7411765, 1.0)
const COLOR_END: Color = Color(0.73333335, 0.24313726, 0.011764706, 1.0)

func _ready() -> void:
	var bars: Array[ColorRect] = []
	var total_width: float = BAR_COUNT * BAR_WIDTH + (BAR_COUNT - 1) * BAR_GAP
	var start_x: float = (size.x - total_width) / 2.0

	for i in range(BAR_COUNT):
		var bar: ColorRect = ColorRect.new()
		bar.size = Vector2(BAR_WIDTH, MIN_HEIGHT)
		bar.position = Vector2(start_x + i * (BAR_WIDTH + BAR_GAP), BASELINE_Y - MIN_HEIGHT)
		bar.color = COLOR_START.lerp(COLOR_END, float(i) / float(BAR_COUNT - 1))
		add_child(bar)
		bars.append(bar)

	LeafTween.stagger(
		bars, STAGGER_DELAY,
		func(bar: ColorRect) -> TweenData:
			return LeafTween.to(
				MIN_HEIGHT, MAX_HEIGHT, DURATION,
				func(height: float) -> void:
					bar.size.y = height
					bar.position.y = BASELINE_Y - height
			).set_ease(LeafTweenEasing.EaseType.IN_OUT_SINE).set_loop(-1).set_ping_pong()
	)
