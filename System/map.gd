extends Node

class_name CMap

static var SINGLETON : CMap

const _GLOBALTIME_MAXDAYS := 365 - 1
const _GLOBALTIME_MAXHOUR := 24 - 1
const _GLOBALTIME_MAXMINS := 60 - 1
const _GLOBALTIME_MAXSECS := 60 - 1

static var GLOBALTIME_YEAR : int = 0
static var GLOBALTIME_DAYS : int = 0 : set = _SETDAYS
static var GLOBALTIME_HOUR : int = 0 : set = _SETHOUR
static var GLOBALTIME_MINS : int = 0 : set = _SETMINS
static var GLOBALTIME_SECS : int = 0 : set = _SETSECS

static func _SETDAYS(DAYS : int) -> void:
	if DAYS > _GLOBALTIME_MAXDAYS:
		DAYS = 0
		GLOBALTIME_YEAR += 1
	
	GLOBALTIME_DAYS = DAYS

static func _SETHOUR(HOUR : int) -> void:
	if HOUR > _GLOBALTIME_MAXHOUR:
		HOUR = 0
		GLOBALTIME_DAYS += 1
	
	GLOBALTIME_HOUR = HOUR

static func _SETMINS(MINS : int) -> void:
	if MINS > _GLOBALTIME_MAXMINS:
		MINS = 0
		GLOBALTIME_HOUR += 1
	
	GLOBALTIME_MINS = MINS

static func _SETSECS(SECS : int) -> void:
	if SECS > _GLOBALTIME_MAXSECS:
		SECS = 0
		GLOBALTIME_MINS += 1
	
	GLOBALTIME_SECS = SECS

static var GLOBALTIME_TICKTIMER : SceneTreeTimer

static var VIEWPOINTCAMERA : RID
static var VIEWPOINTCAMERA_TRANSFORM : Transform3D
static var VIEWPOINTCAMERA_DEGFOVY : float = 75.0
static var VIEWPOINTCAMERA_ZNEAR : float = 0.05
static var VIEWPOINTCAMERA_ZFAR : float = 4000

static var VIEWENVIRONMENT : RID
static var VIEWENVIRONMENT_FOG : bool = true
static var VIEWENVIRONMENT_FOG_COLOR : Color = Color(0.54, 0.55, 0.60)
static var VIEWENVIRONMENT_FOG_ENERGY : float = 1.0
static var VIEWENVIRONMENT_FOG_SCATTER : float = 0.0
static var VIEWENVIRONMENT_FOG_DENSITY : float = 0.01
static var VIEWENVIRONMENT_FOG_AERIAL : float = 0.0
static var VIEWENVIRONMENT_FOG_SKYEFF : float = 1.0
static var VIEWENVIRONMENT_FOG_HEIGHT : float = 0.0
static var VIEWENVIRONMENT_FOG_HEIGHTDENSITY : float = 0.0

static var VIEWENVIRONMENT_TONEMAP : RenderingServer.EnvironmentToneMapper = RenderingServer.ENV_TONE_MAPPER_FILMIC
static var VIEWENVIRONMENT_TONEMAP_EXPOSURE : float = 1.0
static var VIEWENVIRONMENT_TONEMAP_WHITE : float = 1.0

static var VIEWENVIRONMENT_ADJUST : bool = true
static var VIEWENVIRONMENT_ADJUST_BRIGHNSS : float = 1.0
static var VIEWENVIRONMENT_ADJUST_CONTRAST : float = 1.25
static var VIEWENVIRONMENT_ADJUST_SATRTION : float = 0.01
static var VIEWENVIRONMENT_ADJUST_CLCRTN1D : bool = false
static var VIEWENVIRONMENT_ADJUST_COLCORCT : RID

static var VIEWENVIRONMENT_BGMODE : RenderingServer.EnvironmentBG = RenderingServer.ENV_BG_SKY

static var VIEWDIRSUNLIGHT : RID
static var VIEWDIRSUNLIGHT_INSTANCE : RID
static var VIEWDIRSUNLIGHT_INSTANCE_TRANSFORM : Transform3D
static var VIEWDIRSUNLIGHT_SUNCOLOR : Color = Color.WHITE
static var VIEWDIRSUNLIGHT_ENERGY : float = 1.0
static var VIEWDIRSUNLIGHT_AMBIENT : RenderingServer.EnvironmentAmbientSource = RenderingServer.ENV_AMBIENT_SOURCE_SKY
static var VIEWDIRSUNLIGHT_CONTRIB : float = 1.0
static var VIEWDIRSUNLIGHT_REFLEC : RenderingServer.EnvironmentReflectionSource = RenderingServer.ENV_REFLECTION_SOURCE_SKY
static var VIEWDIRSUNLIGHT_SHADOW : bool = true

const _SUNLIGHT_DAYCOLOR : Color = Color.KHAKI
const _SUNLIGHT_NIGHTCOL : Color = Color.BLACK

static func VIWFLW(pivot : Transform3D, rotation : Vector3, distzm : float, delta : float) -> void:
	if not SINGLETON:
		return
	
	var cam_world3D := SINGLETON.get_viewport().world_3d
	
	#rotation
	
	var from : Vector3 = pivot.origin + Vector3(0, 0, distzm)
	var to : Vector3 = pivot.origin
	
	var rotation_basis_up := Basis().rotated(Vector3.UP, rotation.y)
	var rotation_basis_right := Basis().rotated(Vector3.RIGHT, rotation.x)
	var rotated_from : Vector3 = (rotation_basis_up * rotation_basis_right) * (from - pivot.origin) + pivot.origin
	
	#raycast
	
	var xray := PhysicsRayQueryParameters3D.new()
	xray.from = pivot.origin
	xray.to = rotated_from
	xray.hit_back_faces = true
	xray.hit_from_inside = true
	xray.exclude = [CChar.MAINCHAR]
	
	var res := cam_world3D.direct_space_state.intersect_ray(xray)
	
	if res:
		rotated_from = res.position + res.normal * 0.5
	
	#transformation
	
	var xtrans := VIEWPOINTCAMERA_TRANSFORM #SINGLETON.viewpcam.global_transform
	
	xtrans.origin = rotated_from
	xtrans = xtrans.looking_at(to)
	
	VIEWPOINTCAMERA_TRANSFORM = VIEWPOINTCAMERA_TRANSFORM.interpolate_with(
		Transform3D(xtrans), delta * 12.0)
	
	#SINGLETON.viewpcam.global_transform = SINGLETON.viewpcam.global_transform.interpolate_with(
	#	Transform3D(
	#		xtrans), delta * 12.0)


static func INITGLTIMETICK(ticks : float, callback : Callable) -> void:
	if not SINGLETON:
		return
	
	GLOBALTIME_TICKTIMER = SINGLETON.get_tree().create_timer(ticks, false)
	
	await GLOBALTIME_TICKTIMER.timeout
	
	callback.call()
	
	INITGLTIMETICK(ticks, callback)


@export_category("Defines")
@export_range(0, 60) var timetick : float = 1.0

func _time_tick() -> void:
	GLOBALTIME_SECS += 1
	
	"""if GLOBALTIME_SECS < _GLOBALTIME_MAXSECS:
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
				GLOBALTIME_HOUR = 0"""

const _SUNDIR_rY := 150.0
const _SUNDIR_rX := -60.0

func update_sun_light() -> void:
	VIEWDIRSUNLIGHT_SUNCOLOR = lerp(_SUNLIGHT_DAYCOLOR, _SUNLIGHT_NIGHTCOL, GLOBALTIME_HOUR / _GLOBALTIME_MAXHOUR)
	
	var tR := (float(GLOBALTIME_HOUR) / float(_GLOBALTIME_MAXHOUR) )
	var sRDX = lerp(0.0, 360.0, tR)
	
	var sundirbasis : Basis = Basis()
	sundirbasis = sundirbasis.rotated(Vector3.UP, deg_to_rad(_SUNDIR_rY))
	sundirbasis = sundirbasis.rotated(Vector3.LEFT, deg_to_rad(sRDX))
	
	VIEWDIRSUNLIGHT_INSTANCE_TRANSFORM.basis = sundirbasis

func _init() -> void:
	SINGLETON = self
	
	VIEWPOINTCAMERA = RenderingServer.camera_create()
	VIEWENVIRONMENT = RenderingServer.environment_create()
	VIEWDIRSUNLIGHT = RenderingServer.directional_light_create()
	VIEWDIRSUNLIGHT_INSTANCE = RenderingServer.instance_create()

func _enter_tree() -> void:
	INITGLTIMETICK(timetick, _time_tick)
	
	RenderingServer.viewport_attach_camera(get_viewport().get_viewport_rid(), VIEWPOINTCAMERA)
	RenderingServer.camera_set_environment(VIEWPOINTCAMERA, VIEWENVIRONMENT)
	
	RenderingServer.instance_set_base(VIEWDIRSUNLIGHT_INSTANCE, VIEWDIRSUNLIGHT)
	RenderingServer.instance_set_scenario(VIEWDIRSUNLIGHT_INSTANCE, get_viewport().world_3d.scenario)

func _exit_tree() -> void:
	RenderingServer.free_rid(VIEWPOINTCAMERA)
	RenderingServer.free_rid(VIEWENVIRONMENT)
	RenderingServer.free_rid(VIEWDIRSUNLIGHT)
	RenderingServer.free_rid(VIEWDIRSUNLIGHT_INSTANCE)

func _ready() -> void:
	return

func _process(delta: float) -> void:
	RenderingServer.camera_set_perspective(
		VIEWPOINTCAMERA,
		VIEWPOINTCAMERA_DEGFOVY,
		VIEWPOINTCAMERA_ZNEAR,
		VIEWPOINTCAMERA_ZFAR
	)
	RenderingServer.camera_set_transform(VIEWPOINTCAMERA, VIEWPOINTCAMERA_TRANSFORM)
	
	RenderingServer.environment_set_fog(
		VIEWENVIRONMENT,
		VIEWENVIRONMENT_FOG,
		VIEWENVIRONMENT_FOG_COLOR,
		VIEWENVIRONMENT_FOG_ENERGY,
		VIEWENVIRONMENT_FOG_SCATTER,
		VIEWENVIRONMENT_FOG_DENSITY,
		VIEWENVIRONMENT_FOG_AERIAL,
		VIEWENVIRONMENT_FOG_SKYEFF,
		VIEWENVIRONMENT_FOG_HEIGHT,
		VIEWENVIRONMENT_FOG_HEIGHTDENSITY
	)
	RenderingServer.environment_set_tonemap(
		VIEWENVIRONMENT,
		VIEWENVIRONMENT_TONEMAP,
		VIEWENVIRONMENT_TONEMAP_EXPOSURE,
		VIEWENVIRONMENT_TONEMAP_WHITE
	)
	RenderingServer.environment_set_adjustment(
		VIEWENVIRONMENT,
		VIEWENVIRONMENT_ADJUST,
		VIEWENVIRONMENT_ADJUST_BRIGHNSS,
		VIEWENVIRONMENT_ADJUST_CONTRAST,
		VIEWENVIRONMENT_ADJUST_SATRTION,
		VIEWENVIRONMENT_ADJUST_CLCRTN1D,
		VIEWENVIRONMENT_ADJUST_COLCORCT
	)
	RenderingServer.environment_set_background(
		VIEWENVIRONMENT,
		VIEWENVIRONMENT_BGMODE
	)
	
	update_sun_light()
	
	RenderingServer.light_directional_set_shadow_mode(VIEWDIRSUNLIGHT, RenderingServer.LIGHT_DIRECTIONAL_SHADOW_PARALLEL_4_SPLITS)
	RenderingServer.light_directional_set_sky_mode(VIEWDIRSUNLIGHT, RenderingServer.LIGHT_DIRECTIONAL_SKY_MODE_LIGHT_AND_SKY)
	
	RenderingServer.light_set_color(VIEWDIRSUNLIGHT, VIEWDIRSUNLIGHT_SUNCOLOR)
	RenderingServer.light_set_shadow(VIEWDIRSUNLIGHT, VIEWDIRSUNLIGHT_SHADOW)
	
	RenderingServer.light_set_param(VIEWDIRSUNLIGHT, RenderingServer.LIGHT_PARAM_ENERGY, VIEWDIRSUNLIGHT_ENERGY)
	RenderingServer.light_set_param(VIEWDIRSUNLIGHT, RenderingServer.LIGHT_PARAM_SHADOW_BIAS, 1.0)
	RenderingServer.light_set_param(VIEWDIRSUNLIGHT, RenderingServer.LIGHT_PARAM_SHADOW_NORMAL_BIAS, 2.0)
	RenderingServer.light_set_param(VIEWDIRSUNLIGHT, RenderingServer.LIGHT_PARAM_SHADOW_BLUR, 1.0)
	RenderingServer.light_set_param(VIEWDIRSUNLIGHT, RenderingServer.LIGHT_PARAM_TRANSMITTANCE_BIAS, 0.05)
	RenderingServer.light_set_param(VIEWDIRSUNLIGHT, RenderingServer.LIGHT_PARAM_SHADOW_PANCAKE_SIZE, 20.0)
	RenderingServer.light_set_param(VIEWDIRSUNLIGHT, RenderingServer.LIGHT_PARAM_SHADOW_SPLIT_1_OFFSET, 0.1)
	RenderingServer.light_set_param(VIEWDIRSUNLIGHT, RenderingServer.LIGHT_PARAM_SHADOW_SPLIT_2_OFFSET, 0.2)
	RenderingServer.light_set_param(VIEWDIRSUNLIGHT, RenderingServer.LIGHT_PARAM_SHADOW_SPLIT_3_OFFSET, 0.5)
	RenderingServer.light_set_param(VIEWDIRSUNLIGHT, RenderingServer.LIGHT_PARAM_SHADOW_FADE_START, 0.8)
	RenderingServer.light_set_param(VIEWDIRSUNLIGHT, RenderingServer.LIGHT_PARAM_SHADOW_MAX_DISTANCE, 100.0)
	
	RenderingServer.instance_set_transform(VIEWDIRSUNLIGHT_INSTANCE, VIEWDIRSUNLIGHT_INSTANCE_TRANSFORM)
	
	
	
