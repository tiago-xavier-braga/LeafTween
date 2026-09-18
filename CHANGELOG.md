# Changelog

All notable changes to LeafTween are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.0.0] - 2026-09-17

### Added

- Autoload engine (`LeafTween`) driving pooled `TweenData` slots from a
  single `_process(delta)`, with generation-validated `TweenHandle`s for
  `cancel()`/`pause()`/`resume()`.
- Fluent `LeafTween.to()` API with chained setters: `set_ease()`,
  `set_ease_curve()`, `set_delay()`, `set_loop()`, `set_ping_pong()`,
  `set_on_update()`, `set_on_complete()`.
- Full easing function set plus custom easing via a `Curve` resource
  (`set_ease_curve()`).
- `move_along()` for Bezier and Catmull-Rom curve-based motion.
- `LeafTweenSequence` for series (`append()`) and parallel (`join()`) tween
  composition, with looping and ping-pong.
- `stagger()` to animate a list of nodes with an incremental delay in a
  single call.
- Node helpers for common types: `move()`, `resize()`, `fade()`,
  `modulate()`.
