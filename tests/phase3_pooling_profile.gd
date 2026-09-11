extends Node

const TWEEN_COUNT: int = 800
const TWEEN_DURATION: float = 0.4
const SAMPLE_INTERVAL_SEC: float = 0.1
const TOTAL_SAMPLES: int = 50

var _elapsed_since_sample: float = 0.0
var _samples_taken: int = 0
var _total_completions: int = 0

func _ready() -> void:
	for i in range(TWEEN_COUNT):
		_start_tween(i)
	print("sample,static_memory_kb,object_count,total_completions")

func _process(delta: float) -> void:
	_elapsed_since_sample += delta
	if _elapsed_since_sample < SAMPLE_INTERVAL_SEC:
		return
	_elapsed_since_sample = 0.0
	_samples_taken += 1

	var static_memory_kb: float = Performance.get_monitor(Performance.MEMORY_STATIC) / 1024.0
	var object_count: int = int(Performance.get_monitor(Performance.OBJECT_COUNT))
	print("%d,%.1f,%d,%d" % [_samples_taken, static_memory_kb, object_count, _total_completions])

	if _samples_taken >= TOTAL_SAMPLES:
		get_tree().quit()

func _start_tween(index: int) -> void:
	LeafTween.to(
		0.0,
		1.0,
		TWEEN_DURATION,
		func(_value: float) -> void: pass
	).set_on_complete(func() -> void:
		_total_completions += 1
		_start_tween(index)
	)
