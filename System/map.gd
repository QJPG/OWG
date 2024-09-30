extends Node

class_name CMap

static var SINGLETON : CMap

const _GLOBALTIME_MAXHOUR := 24 - 1
const _GLOBALTIME_MAXMINS := 60 - 1
const _GLOBALTIME_MAXSECS := 60 - 1

static var GLOBALTIME_HOUR : int = 0
static var GLOBALTIME_MINS : int = 0
static var GLOBALTIME_SECS : int = 0

static func VIWFLW(targ : Vector3, distzm := 2.0) -> void:
	if not SINGLETON:
		return
	
	#add a raycast to get camera direction
	
	SINGLETON.viewpcam.global_position = SINGLETON.viewpcam.global_position.direction_to(targ)

@export_category("World Map Defines")
@export var sunlight : DirectionalLight3D
@export var worldenv : WorldEnvironment
@export var viewpcam : Camera3D
@export var timetimr : Timer

@export_category("Time")
@export_range(0, 60) var timetick : float = 1.0
@export var time_active : bool : set = _set_time_active


func _set_time_active(active : bool) -> void:
	time_active = active
	
	if not time_active:
		timetimr.timeout.disconnect(_time_tick)
		timetimr.stop()
	else:
		if not timetimr.is_inside_tree():
			await timetimr.tree_entered
		
		timetimr.timeout.connect(_time_tick)
		timetimr.start(timetick)

func _time_tick() -> void:
	if GLOBALTIME_SECS < _GLOBALTIME_MAXSECS:
		GLOBALTIME_SECS += 1
	else:
		GLOBALTIME_SECS = 0
		
		if GLOBALTIME_MINS < _GLOBALTIME_MAXMINS:
			GLOBALTIME_MINS += 1
		else:
			GLOBALTIME_MINS = 0
			
			if GLOBALTIME_HOUR < _GLOBALTIME_MAXHOUR:
				GLOBALTIME_HOUR += 1
			else:
				GLOBALTIME_HOUR = 0

func _init() -> void:
	SINGLETON = self

func _enter_tree() -> void:
	return

func _exit_tree() -> void:
	return

func _ready() -> void:
	return

func _process(delta: float) -> void:
	return
