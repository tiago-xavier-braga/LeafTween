# API Design — Phase 0 Baseline

Sketch of LeafTween's public API surface, written before any engine internals
(see [`roadmap.md`](roadmap.md), Phase 0). Names follow GDScript conventions
(`snake_case`, static typing) and the architecture decisions the roadmap has
already made (autoload singleton, `{index, generation}` handles, `Curve`
easing).

This is notes, not code — nothing here needs to compile yet.

## 1. Entry point — generic primitive (Phase 1)

```gdscript
LeafTween.to(from: Variant, to: Variant, duration: float, on_update: Callable) -> LeafTweenHandle
```

- Matches the signature the roadmap already fixed for Phase 1.
- `Variant` because Phase 2 adds generic value support (`float`,
  `Vector2`/`Vector3`, `Color`) via an interpolation `Callable` — the
  primitive itself shouldn't care about the value type.

## 2. Chained config (Phase 2+)

```gdscript
LeafTween.to(position, target_position, 1.0, on_update) \
	.set_ease(LeafTween.EASE_OUT_QUAD) \
	.set_ease_curve(my_curve) \
	.set_delay(0.5) \
	.set_on_complete(on_done)
```

- `set_ease_curve(Curve)` accepts a `Curve` resource as a custom easing
  source, sampled per-frame. The value-add (per the roadmap) is that a
  `Curve` is editable visually in the inspector, without touching code.
- Every setter returns `self` (the handle), per the roadmap's fluent-API
  decision.

## 3. Handle shape

The roadmap commits (Phase 3) to an `{index, generation}` handle so a stale
reference to a recycled pool slot is detected instead of silently touching
the wrong tween. Sketch:

```gdscript
class_name LeafTweenHandle
extends RefCounted

var _index: int
var _generation: int

func set_ease(ease_type: int) -> LeafTweenHandle: ...
func set_ease_curve(curve: Curve) -> LeafTweenHandle: ...
func set_delay(seconds: float) -> LeafTweenHandle: ...
func set_on_complete(callback: Callable) -> LeafTweenHandle: ...
func cancel() -> void: ...
func pause() -> void: ...
func resume() -> void: ...
```

**Open question, not decided here:** should `cancel()`/`pause()` live on the
handle instance (`handle.cancel()`), or stay a static call
(`LeafTween.cancel(handle)`)? Instance-side reads closer to the fluent
chain; static-side keeps all pool access behind one entry point. Both work
fine with the generation check — worth picking before Phase 3 locks in the
pool internals.

## 4. Node-level static helpers (Phase 6)

```gdscript
LeafTween.move(node, target_position, duration)
LeafTween.move_x(node, target_x, duration)
LeafTween.scale(node, target_scale, duration)
LeafTween.rotate(node, target_rotation_degrees, duration)
LeafTween.modulate(canvas_item, target_color, duration)
```

- Each is sugar for `.to()` that supplies the `on_update` Callable
  internally (e.g. `move` does `node.position = value`).

## 5. Sequencing (Phase 5)

```gdscript
LeafTweenSequence.new() \
    .append(LeafTween.move(node, pos_a, 1.0)) \
    .join(LeafTween.rotate(node, 90.0, 1.0)) \
    .append(LeafTween.move(node, pos_b, 1.0)) \
    .set_loop(2) \
    .set_ping_pong()
```

- `append()` runs steps in series, `join()` runs a step in parallel with the
  previous one.

## 6. move_along (Phase 4)

Unifies bezier and Catmull-Rom path following with easing, callbacks, and
sequencing behind one call:

```gdscript
LeafTween.move_along(node, path: BezierPath, duration)
LeafTween.move_along(node, spline: CatmullRomSpline, duration) \
    .set_ease(LeafTween.EASE_IN_OUT_CUBIC)
```

## 7. stagger() (Phase 6)

Takes a factory `Callable` per node, so each staggered step can be any kind
of tween:

```gdscript
LeafTween.stagger(
    list_items,
    0.05,
    func(n: Node) -> LeafTweenHandle:
        return LeafTween.move(n, n.position + Vector2(0, -20), 0.3)
)
```

## Open questions to settle before Phase 1

- `cancel`/`pause` on the handle vs. as a static call (§3).
- Does `.to()` take an explicit ease argument, or default to linear until
  Phase 2 adds `.set_ease()`? Phase 1 is linear-only per the roadmap, so
  probably the latter.
- `on_update`/`on_complete`: constructor args vs. setter-only. The sketch
  above splits them — update callback in the call itself, completion via a
  setter.
