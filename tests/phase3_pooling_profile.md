# Phase 3 — Pooling Allocation Profile

Deliverable for the roadmap's Phase 3 profiling step: "Profile allocations
before/after with Godot's Debugger → Monitors, animating 500+ nodes at once."

## Methodology

- Harness: `tests/phase3_pooling_profile.gd` + `.tscn`. Starts 800 concurrent
  tweens (above the roadmap's "500+" bar, under `MAX_TWEENS = 1024`), each
  restarting itself from `on_complete` — continuous pool churn instead of a
  single burst.
- Samples `Performance.MEMORY_STATIC` and `Performance.OBJECT_COUNT` every
  0.1s for 5s (50 samples), run headless:
  `godot --headless --path . res://tests/phase3_pooling_profile.tscn`
- Compared against the pre-pooling implementation at commit `115d040`
  (`Array[TweenData]` + `TweenData.new()` per `to()` call, `.remove_at()` on
  completion) — same harness, run from a throwaway git worktree checked out
  at that commit.

## Results

Both runs performed the same amount of work (9600 tween-cycle handoffs over
5s, confirmed by `total_completions`). In both, `static_memory_kb` and
`object_count` were a **single constant value across all 50 samples**:

| Version | static_memory_kb | object_count |
|---|---|---|
| Before pooling (`115d040`) | 58652.7 | 2287 |
| After pooling (`79eb2dd`) | 59204.9 | 2512 |

`total_completions` climbed identically in both (every ~0.4s, in steps of
800) — e.g. after pooling:

```
sample,static_memory_kb,object_count,total_completions
1,59204.9,2512,0
9,59204.9,2512,1600
17,59204.9,2512,3200
25,59204.9,2512,4800
33,59204.9,2512,6400
41,59204.9,2512,8000
48,59204.9,2512,9600
```

## Interpretation

- A flat memory graph in **both** versions does not mean pooling made no
  difference — it means `Performance.MEMORY_STATIC`/`OBJECT_COUNT`, sampled
  as snapshots, can't see the churn either way. GDScript `RefCounted`
  objects free deterministically the instant their refcount hits zero, so
  even the unpooled version never accumulates garbage for a memory monitor
  to catch. **Watching the monitor graph alone would not have proven the
  pool was working.**
- The real difference is allocation *call count*, not peak memory: the
  unpooled version called `TweenData.new()` (plus its implicit destructor)
  once per handoff — 9600 alloc/free pairs over this 5s run, and it would
  keep growing linearly with uptime. The pooled version calls
  `TweenData.new()` `MAX_TWEENS` (1024) times total, once at startup in
  `_ready()`, and zero times after that no matter how long the app runs or
  how many tweens cycle through.
- The baseline `object_count` is higher *after* pooling (2512 vs 2287)
  because the pool reserves all 1024 slots upfront whether they're active or
  not, versus the unpooled version's array only ever holding the ~800
  concurrently-live `TweenData` instances. That's the trade-off the
  roadmap's pool/generation-counter design is making: a small, fixed,
  one-time cost at startup in exchange for zero allocation calls at runtime,
  ever again.

## Reproducing / watching it live

- Headless (produces the numbers above):
  `godot --headless --path . res://tests/phase3_pooling_profile.tscn`
- In-editor: open the project, run `tests/phase3_pooling_profile.tscn`, and
  watch Debugger → Monitors → Memory (Static Memory) / Object Count while
  `total_completions` climbs in the Output panel — the monitors should read
  flat for the reasons above, which is itself the thing worth seeing
  firsthand.
