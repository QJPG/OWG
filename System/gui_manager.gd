extends CanvasLayer

class_name GUIManager

static var SINGLETON : GUIManager
static var ISWAITING : bool

"""
Wait for the universal counter to finish before calling the next interface.
"""

static func WAITCALL(function : Callable, usecs : float = 1.0 / 2.0) -> void:
	if not SINGLETON:
		return
	
	if not ISWAITING:
		function.call()
		return
	
	await SINGLETON.get_tree().create_timer(usecs).timeout
	WAITCALL(function, usecs)


static func WARN(message : String, time : float) -> void:
	if not SINGLETON:
		return
	
	if ISWAITING:
		WAITCALL(WARN.bind(message, time))
		return
	
	WAIT(time)
	
	SINGLETON._object_warn_richlabel.text = message
	SINGLETON._object_warn_container.show()
	
	await SINGLETON.get_tree().create_timer(time).timeout
	
	SINGLETON._object_warn_container.hide()


static func FLSH() -> void:
	if not SINGLETON:
		return
	
	SINGLETON._object_flash_colorret.show()
	
	var t := SINGLETON.create_tween()
	
	t.tween_property(SINGLETON._object_flash_colorret, "modulate:a", 1.0, 0.0)
	t.tween_property(SINGLETON._object_flash_colorret, "modulate:a", 0.0, 0.1)
	
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_CUBIC)
	
	t.play()
	
	await t.finished
	
	SINGLETON._object_flash_colorret.hide()

"""
Universal counter that prevents one interface from being called over another.
"""

static func WAIT(time : float) -> void:
	if not SINGLETON:
		return
	
	ISWAITING = true
	await SINGLETON.get_tree().create_timer(time).timeout
	ISWAITING = false

var in_menu : bool : set = _set_menu_visiblity

@export_category("Warning")
@export var _object_warn_container : PanelContainer
@export var _object_warn_richlabel : RichTextLabel

@export_category("Flash")
@export var _object_flash_colorret : ColorRect

@export_category("Menu")
@export var _object_menu_panel : Panel

func _set_menu_visiblity(is_visible : bool) -> void:
	in_menu = is_visible
	
	_object_menu_panel.visible = is_visible
	
	if in_menu:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	get_tree().paused = in_menu

func _init() -> void:
	unique_name_in_owner = true
	
	SINGLETON = self


func _enter_tree() -> void:
	return


func _exit_tree() -> void:
	return


func _ready() -> void:
	in_menu = false
	
	WAIT(1.0)
	WARN(lstr.Lstr("warn.controls.a"), 9.0)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			FLSH()
			in_menu = !in_menu

func _process(delta: float) -> void:
	return
