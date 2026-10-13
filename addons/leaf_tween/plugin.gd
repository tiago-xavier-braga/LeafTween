@tool
## Registers the [code]LeafTween[/code] autoload when the plugin is enabled
## and removes it when the plugin is disabled.
extends EditorPlugin

const AUTOLOAD_NAME: String = "LeafTween"
const AUTOLOAD_PATH: String = "res://addons/leaf_tween/leaf_tween.gd"

func _enable_plugin() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)

func _disable_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
