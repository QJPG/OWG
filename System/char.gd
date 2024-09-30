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

func _ready() -> void:
	return

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var rel := event.relative as Vector2
		
		var _parent_ := get_viewport().get_camera_3d().get_parent()
		
		if _parent_ is Node3D:
			_parent_.rotate_y(rel.x * -0.005)
		
		get_viewport().get_camera_3d().rotate_x(rel.y * -0.005)

var direction : Vector3

func _physics_process(delta: float) -> void:
	var stregth := int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A))
	var forward := int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W))
	
	direction.x = stregth * 8.0
	direction.z = forward * 8.0
	direction = get_viewport().get_camera_3d().global_basis.x * direction.x + get_viewport().get_camera_3d().global_basis.z * direction.z
	
	if Input.is_key_pressed(KEY_SPACE):
		JUMP(self, 1.0 / 2.0)
	
	MOVE(self, direction.x, direction.z, delta)
	
	
	
