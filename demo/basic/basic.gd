extends Control

@export var move_image: ColorRect
@export var final_position: float = 500.0
@export var duration: float = 1.0
@export var color_finish: Color = Color.WHITE

func _ready() -> void:
    var tween: LeafTween.TweenData = LeafTween.to(
        move_image.position.x,
        final_position, duration,
        func(value: float) -> void:
            move_image.position.x = value
    )
    tween.on_complete = func() -> void:
        move_image.modulate = color_finish
