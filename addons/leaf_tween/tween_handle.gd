## An opaque [code]{index, generation}[/code] reference to a pooled tween's
## slot, used with [method LeafTween.cancel], [method LeafTween.pause], and
## [method LeafTween.resume]. Obtained via [method TweenData.get_handle] —
## not meant to be constructed directly. A handle whose slot has since been
## reused by a different tween is detected as stale and silently ignored.
class_name TweenHandle extends RefCounted

var index: int
var generation: int
