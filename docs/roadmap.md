# Roadmap

Implementation plan for building LeafTween from scratch: a tweening engine
for Godot, designed around well-known game-engine architecture patterns —
object pooling, generation counters, a single central update loop, and a
fluent API.

## Core Architecture

- An autoload singleton `Node` overrides `_process(delta)` and drives every
  active tween — no per-tween node instancing.
- A pre-allocated `Array` of `TweenData` slots, recycled via active/inactive
  flags — no new tween object allocated at runtime past initialization.
- Handle = `{ index, generation }`: a stale reference to a recycled slot is
  detected instead of silently touching the wrong tween.
- A `TweenAction` enum driving a `match` statement per animation type,
  instead of a subclass per type.
- Every config method returns `self`, enabling chained calls
  (`LeafTween.move(node, target, duration).set_ease(...).set_delay(...)`).

## Value-Add Features

Three features go beyond reproducing the native `Tween`'s ergonomics. Each is
paired with a manual workaround built in the same phase as the feature
itself, to make the gap it fills concrete rather than asserted:

- **Custom easing via `Curve` resource** (Phase 2) — the native `Tween` only
  accepts the fixed `Tween.TransitionType`/`EaseType` enums. A `Curve` is
  editable visually in the Godot inspector, letting an ease be tuned without
  touching code. The native `Tween` only reaches this via a `tween_method()` +
  manual `Curve.sample()` workaround.
- **`stagger()` helper** (Phase 6) — animating a list of nodes with an
  incremental delay between each (cascading UI reveal, list items appearing in
  sequence) has no one-call solution in the native `Tween`; it always needs a
  hand-written loop.
- **Curve-based motion** (`move_along`, Phase 4) — Bezier/Catmull-Rom path
  following exists in Godot via `Curve2D`/`PathFollow2D`, but disconnected
  from easing, callbacks, and sequencing. `move_along()` unifies the three.

## Prerequisites

- [ ] GDScript static typing (`var x: float`, `-> void`)
- [ ] `Callable` / `Signal` as the callback mechanism (GDScript's equivalent of `Action`/delegates)
- [ ] `class_name` + `RefCounted` vs plain `Dictionary` for pooled data
- [ ] Pre-allocated typed `Array`s and why `Variant` boxing still costs in GDScript
- [ ] Easing math — Robert Penner's equations
- [ ] Bezier curves and Catmull-Rom splines
- [ ] Godot's `Curve` resource API (`Curve.sample()`) for custom easing curves

## Phased Plan

### Phase 0 — Baseline
- ~~Sketch the public API you want (`LeafTween.move(...)`, chained setters) before writing engine internals.~~
- ~~**Deliverable:** written notes on the desired API shape.~~

### Phase 1 — Minimal engine
- ~~`addons/leaf_tween/leaf_tween.gd` autoload with `_process(delta)`.~~
- ~~`TweenData` inner class: `from`, `to`, `duration`, `elapsed`, `on_update: Callable`, `on_complete: Callable`.~~
- ~~Plain `Array[TweenData]` (optimize later).~~
- ~~Static `LeafTween.to(from, to, duration, on_update)`.~~
- ~~Linear interpolation only, no easing yet.~~
- ~~**Deliverable:** `demo/basic/` scene animating a node's position with a completion callback.~~

### Phase 2 — Easing + fluent API
- Implement at least 6 easing functions from the math formulas (linear, quad in/out/inout, cubic, bounce) — no copying from Godot's built-in `Tween.TransitionType`.
- Reproduce a custom-curve ease by hand with the native `Tween` (`tween_method()` + manual `Curve.sample()`), to see firsthand the workaround this phase replaces.
- Accept a `Curve` resource as a custom easing source (`.set_ease_curve(curve)`), sampled per-frame — the native `Tween` has no first-class equivalent, only the manual workaround above.
- Config methods return `self` for chaining (`.set_ease()`, `.set_delay()`).
- Generic value support (`float`, `Vector2`/`Vector3`, `Color`) via an interpolation `Callable`.
- **Deliverable:** `demo/easing/` comparing a custom `ease_out_bounce` against Godot's built-in equivalent, side by side, plus a `Curve`-driven ease against the manual `tween_method()`/`Curve.sample()` workaround built above.

### Phase 3 — Pooling & generation counters
- Replace `Array[TweenData]` with a fixed-size, pre-allocated array.
- Implement the handle (`index` + `generation`) pattern; `cancel`/`pause` validate the generation before acting on a slot.
- Track the highest used index so the update loop doesn't scan unused slots.
- Profile allocations before/after with Godot's Debugger → Monitors, animating 500+ nodes at once.
- **Deliverable:** a note/screenshot in `tests/` showing steady-state allocations near zero.

### Phase 4 — Motion curves
- `BezierPath` (cubic, 4 control points) with `get_point(t)`.
- Catmull-Rom spline over a list of control points.
- Wire into `LeafTween.move_along(node, path, duration)`.
- **Deliverable:** `demo/curves/` scene following a spline track.

### Phase 5 — Sequencing
- `LeafTweenSequence` with `.append()` (series) and `.join()` (parallel).
- `.set_loop(n)` and `.set_ping_pong()`.
- **Deliverable:** `demo/sequence/` — 3 tweens in series + 1 in parallel, looping twice, triggered by a button.

### Phase 6 — Polish
- Static helper methods for common node types (`Node2D`, `Control`, `CanvasItem` modulate).
- `Control`/UI tweening support.
- Reproduce a staggered cascade by hand with the native `Tween` (a loop with incremental delay), to see firsthand the workaround `stagger()` replaces.
- `LeafTween.stagger(nodes, delay_between, ...)` to animate a list of nodes with an incremental delay in one call, handling cancel-mid-stagger cleanly.
- Lightweight test coverage in `tests/` (GUT, or a minimal custom `expect()` runner) for cancel/pause/pool-reuse edge cases, including stagger cancellation.
- **Deliverable:** the addon usable standalone (drop `addons/leaf_tween/` into another project), with `demo/stagger/` comparing `stagger()` against the manual loop built above.

## Self-Check Questions

1. Why avoid instancing a `Node`/object per tween, and why does that matter more once hundreds run at once?
2. What breaks if the pool has no generation counter and a tween is canceled through a stale handle?
3. Why is optional per-tween data (curve/extra callbacks) worth keeping out of the base `TweenData` shape?
4. Why expose both `delta` and an unscaled/process-independent delta, so UI can animate while the game is paused?
5. How do you implement ping-pong/looping by transforming `t` before easing, without duplicating interpolation code?
6. Why is `TweenAction` enum + `match` faster and simpler here than a subclass per animation type?
7. Why does accepting a `Curve` resource for custom easing add real value over the native `Tween.TransitionType` enum, and what does a non-programmer gain from it that a code-only API doesn't provide?
8. What does `stagger()` need to handle (partial cancellation, staggered completion callbacks) that a naive `for` loop calling `LeafTween.move()` in sequence wouldn't get right?

## Done Criteria

- Can explain the pool + generation-counter + central-update-loop architecture from memory, no notes.
- Engine implemented end-to-end: pooling, easing, curves, sequencing.
- 1000+ simultaneous tweens run with near-zero steady-state allocation (verified in Godot's profiler).
- Each value-add feature (`Curve` easing, `stagger()`, `move_along()`) has a demo scene showing it next to the manual workaround it replaces, built in the same phase as the feature for direct comparison.

## References

- [Robert Penner's easing equations](http://robertpenner.com/easing/)
- *Game Programming Patterns* (Robert Nystrom) — Object Pool, Update Method, Component chapters
- Catmull-Rom spline / Bezier curve — any introductory computer-graphics reference on curve interpolation
