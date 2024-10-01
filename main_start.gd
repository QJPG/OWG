extends Node


func _init() -> void:
	CSTD.CSETG("OpenWorld/config.cfg")


func _enter_tree() -> void:
	return


func _ready() -> void:
	return


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_R:
			CMap.GLOBALTIME_HOUR += 1


func _exit_tree() -> void:
	return
