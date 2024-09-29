extends CharacterBody3D

class_name CCharBehavior

static var S_CHAR_GRAVITY : float = -9.8
static var S_CHAR_ACCELER : float = 1.0

static func JUMP(char : CharacterBody3D, force : float) -> void:
	if char.is_on_floor():
		char.velocity.y = -S_CHAR_GRAVITY * force

static func MOVE(char : CharacterBody3D, x : float, z: float, dt : float) -> void:
	char.velocity.x = x
	char.velocity.z = z
	
	if not char.is_on_floor():
		char.velocity.y += S_CHAR_GRAVITY * dt
	
	char.velocity *= S_CHAR_ACCELER
	
	char.move_and_slide()

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
	direction.x = Input.get_axis("MOV_STRH_LEFT", "MOV_STRH_RIGHT") * 8.0
	direction.z = Input.get_axis("MOV_FW", "MOV_BW") * 8.0
	direction = get_viewport().get_camera_3d().global_basis.x * direction.x + get_viewport().get_camera_3d().global_basis.z * direction.z
	
	if Input.is_action_pressed("JMP"):
		JUMP(self, 1.0 / 2.0)
	
	MOVE(self, direction.x, direction.z, delta)
	
	
	
