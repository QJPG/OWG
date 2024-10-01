extends CharacterBody3D

class_name CChar

static var GLOBAL_GRAVITY : float = -9.8
static var GLOBAL_ACCELER : float = 1.0

static var MAINCHAR : CChar = null

static func JUMP(char : CharacterBody3D, force : float) -> void:
	if char.is_on_floor():
		char.velocity.y = -GLOBAL_GRAVITY * force

static func MOVE(char : CharacterBody3D, x : float, z: float, dt : float) -> void:
	char.velocity.x = x
	char.velocity.z = z
	
	if not char.is_on_floor():
		char.velocity.y += GLOBAL_GRAVITY * dt
	
	char.velocity *= GLOBAL_ACCELER
	
	char.move_and_slide()

@export var mainchar : bool : set = _set_as_mainchar
@export var modelview : Node3D

func _set_as_mainchar(active : bool) -> void:
	mainchar = active
	
	if active:
		MAINCHAR = self
		return
	
	if MAINCHAR == self:
		MAINCHAR = null
		return


func _init() -> void:
	return

var camera_pivot : Transform3D
var camera_rotat : Vector3

func _ready() -> void:
	return

func _input(event: InputEvent) -> void:
	if MAINCHAR == self:
		if event is InputEventMouseMotion:
			var rel := event.relative as Vector2
		
			camera_rotat.x += rel.y * -0.005
			camera_rotat.y += rel.x * -0.005
		
			camera_rotat.x = deg_to_rad(clamp(rad_to_deg(camera_rotat.x), -80, 80))

var direction : Vector3

func _physics_process(delta: float) -> void:
	if MAINCHAR == self:
		var stregth := int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A))
		var forward := int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W))
		
		var camera_transform := CMap.VIEWPOINTCAMERA_TRANSFORM
		
		direction.x = stregth * 2.0
		direction.z = forward * 2.0
		direction = camera_transform.basis.x * direction.x + camera_transform.basis.z * direction.z
	
		if Input.is_key_pressed(KEY_SPACE):
			JUMP(self, 1.0 / 2.0)
		
		camera_pivot.origin = global_position + Vector3(0, 2, 0)
	
		CMap.VIWFLW(camera_pivot, camera_rotat, 5.0, delta)
	
	MOVE(self, direction.x, direction.z, delta)
	
	if (Vector3(1, 0, 1) * velocity).length() > 0:
		if modelview:
			var xtrans_modelview := modelview.transform
			var xtrans_lookingat := xtrans_modelview.looking_at(velocity * Vector3(1, 0, 1) + xtrans_modelview.origin)
			
			modelview.transform = modelview.transform.interpolate_with(xtrans_lookingat, 5.0 * delta)

	
