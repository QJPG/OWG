extends Node

@export var first_button : Button : set = _set_first_button

func _set_first_button(button : Button) -> void:
	first_button = button
	await first_button.tree_entered
	first_button.grab_focus()

func _ready() -> void:
	return
