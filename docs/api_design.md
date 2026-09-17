# API Design — Phase 0 Baseline

Sketch of LeafTween's public API surface, written before any engine internals
(see [`roadmap.md`](roadmap.md), Phase 0). Names follow GDScript conventions
(`snake_case`, static typing) and the architecture decisions the roadmap has
already made (autoload singleton, `{index, generation}` handles, `Curve`
easing).

This is notes, not code — nothing here needs to compile yet.

> The roadmap's phased plan (0-6) is now complete. This file is kept as the
> original pre-implementation sketch; sections whose names or shape changed
> during implementation carry a **Shipped as:** note pointing at what
> actually exists.

## 1. Entry point — generic primitive (Phase 1)

```gdscript
LeafTween.to(from: Variant, to: Variant, duration: float, on_update: Callable) -> LeafTweenHandle
```

- Matches the signature the roadmap already fixed for Phase 1.
- `Variant` because Phase 2 adds generic value support (`float`,
  `Vector2`/`Vector3`, `Color`) via an interpolation `Callable` — the
  primitive itself shouldn't care about the value type.

**Shipped as:** `LeafTween.to(...) -> TweenData` (§3 explains the
`TweenData`/`TweenHandle` split).

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

**Shipped as:** `.set_ease(LeafTweenEasing.EaseType.OUT_QUAD)` — the ease
enum lives on `LeafTweenEasing`, not directly on `LeafTween`.

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

**Shipped as — resolved differently than sketched here:** the fluent
setters and the `{index, generation}` handle ended up on two separate
classes instead of one. `TweenData` (returned by `to()`/`move()`/etc.) holds
the fluent config setters (`set_ease()`, `set_delay()`, ...) plus a
`get_handle() -> TweenHandle`. The plain `TweenHandle` — just `index` +
`generation`, no methods — is what `LeafTween.cancel()`/`pause()`/`resume()`
take, resolving the open question above in favor of the static-call side.
Splitting them keeps the handle passable/storable without dragging the
whole config-setter surface along with it.

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

**Shipped as:** `move()` and `modulate()` landed as sketched; `move_x()`,
`scale()`, `rotate()` didn't ship, and `resize()`/`fade()` were added
instead (not in this original sketch) — `resize()` because `Control` has no
`Node2D` equivalent otherwise, `fade()` because animating just
`modulate.a` (vs. the full `Color`) is common enough in UI work to earn its
own call:

```gdscript
LeafTween.move(node: Node, target: Vector2, duration: float) -> TweenData
LeafTween.resize(control: Control, target_size: Vector2, duration: float) -> TweenData
LeafTween.fade(canvas_item: CanvasItem, target_alpha: float, duration: float) -> TweenData
LeafTween.modulate(canvas_item: CanvasItem, target_color: Color, duration: float) -> TweenData
```

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

**Shipped as:** matches the sketch (`rotate()` aside — use `fade()` or
`to()` instead, per §4). `append()`/`join()` just offset each `TweenData`'s
`delay` along a shared timeline — no separate runtime for the sequence
itself, since the tweens are already live in the pool the moment
`LeafTween.move()`/`to()` acquires them.

## 6. move_along (Phase 4)

Unifies bezier and Catmull-Rom path following with easing, callbacks, and
sequencing behind one call:

```gdscript
LeafTween.move_along(node, path: BezierPath, duration)
LeafTween.move_along(node, spline: CatmullRomSpline, duration) \
    .set_ease(LeafTween.EASE_IN_OUT_CUBIC)
```

**Shipped as:** matches the sketch — `move_along(node: Node2D, path: Resource, duration: float) -> TweenData`,
accepting either `LeafTweenBezierPath` or `LeafTweenCatmullRomSpline` via
duck typing (`get_point(t)`), same ease enum caveat as §2.
`demo/curves/curves.gd` also builds the manual `Curve2D` + `PathFollow2D` +
`tween_method()` equivalent for direct comparison, per the Done Criteria.

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

**Shipped as:** matches the sketch almost exactly —
`stagger(nodes: Array, delay_between: float, tween_factory: Callable) -> Array[TweenData]`,
factory returns `TweenData` (not `LeafTweenHandle`, per §3). Internally it's
just `tween_factory.call(nodes[i])` then `tween_data.delay += i * delay_between`
per node, so cancel-mid-stagger is "free" — canceling one entry via its own
`TweenData.get_handle()` never touches the others.

## Open questions to settle before Phase 1

- `cancel`/`pause` on the handle vs. as a static call (§3).
- Does `.to()` take an explicit ease argument, or default to linear until
  Phase 2 adds `.set_ease()`? Phase 1 is linear-only per the roadmap, so
  probably the latter.
- `on_update`/`on_complete`: constructor args vs. setter-only. The sketch
  above splits them — update callback in the call itself, completion via a
  setter.
