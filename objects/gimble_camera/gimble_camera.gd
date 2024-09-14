extends Node3D
class_name GimbleCamera

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal yaw_changed(yaw : float)
signal pitch_changed(pitch : float)
signal zoom_changed(z : float)

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const FLOAT_THRESHOLD : float = 0.001

const MIN_PITCH_ANGLE : float = -1.570796
const MAX_PITCH_ANGLE : float = 1.570796

const PITCH_ANGLE : float = deg_to_rad(360.0)
const YAW_ANGLE : float = deg_to_rad(360.0)

const ZOOM_RATE : float = 10.0

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_subgroup("Camera Properties")
@export var current : bool = false:							set=set_current
@export_range(1.0, 179.0) var fov : float = 75.0:			set=set_fov
@export_range(0.001, 10.0, 0.001) var near : float = 0.05:	set=set_near
@export_range(0.01, 4000.0, 0.01) var far : float = 4000.0:	set=set_far
@export var attributes : CameraAttributes:					set=set_attributes

@export_subgroup("Zoom")
@export_range(0.0, 10.0, 0.001) var min_zoom = 1.0:			set=set_min_zoom
@export_range(0.0, 200.0, 0.001) var max_zoom = 20.0:		set=set_max_zoom

@export_subgroup("Misc")
@export var input_on_captured_only : bool = true

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _mouse_sensitivity : Vector2 = Vector2(0.025, 0.025)
var _look : Vector2 = Vector2.ZERO
var _zoom : float = 0.0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _camera: Camera3D = $InnerGimble/Camera3D
@onready var _inner_gimble: Node3D = $InnerGimble


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_min_zoom(z : float) -> void:
	if z >= 0.0 and z < 10.0:
		min_zoom = z
		if min_zoom > max_zoom:
			max_zoom = min_zoom

func set_max_zoom(z : float) -> void:
	if z >= 0.0 and z < 200.0:
		max_zoom = z
		if max_zoom < min_zoom:
			min_zoom = max_zoom

func set_current(c : bool) -> void:
	if current != c:
		current = c
		_UpdateCameraProperties()

func set_fov(f : float) -> void:
	if fov != f and f >= 1.0 and f <= 179.0:
		fov = f
		_UpdateCameraProperties()

func set_near(n : float) -> void:
	if near != n and n >= 0.001 and n <= 10.0:
		near = n
		_UpdateCameraProperties()

func set_far(f : float) -> void:
	if far != f and f >= 0.01 and f <= 4000.0:
		far = f
		_UpdateCameraProperties()

func set_attributes(a : CameraAttributes) -> void:
	if a != attributes:
		attributes = a
		_UpdateCameraProperties()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_UpdateCameraProperties()

func _unhandled_input(event: InputEvent) -> void:
	if input_on_captured_only and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: return
	
	if event is InputEventMouseMotion:
		_UpdateRotations(event.relative * _mouse_sensitivity)
	else:
		if InputUtils.Event_Is_Action(event, [&"look_up", &"look_down"]):
			_look.y = Input.get_axis(&"look_down", &"look_up")
		if InputUtils.Event_Is_Action(event, [&"look_left", &"look_right"]):
			_look.x = Input.get_axis(&"look_left", &"look_right")
		if InputUtils.Event_Is_Action(event, [&"zoom_in", &"zoom_out"]):
			_zoom = Input.get_axis(&"zoom_in", &"zoom_out")

func _process(delta: float) -> void:
	_UpdateRotations(Vector2(
		(_look.x * YAW_ANGLE * delta),
		(_look.y * PITCH_ANGLE * delta)
	))

	if _camera != null:
		var _last_z : float = _camera.position.z
		_camera.position.z = max(min_zoom, min(max_zoom, _camera.position.z + (ZOOM_RATE * _zoom * delta)))
		if abs(_last_z - _camera.position.z) < FLOAT_THRESHOLD:
			zoom_changed.emit(_camera.position.z)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateRotations(look : Vector2) -> void:
	var _last_pitch : float = _inner_gimble.rotation.x
	_inner_gimble.rotation.x = clamp(
		_inner_gimble.rotation.x + look.y,
		MIN_PITCH_ANGLE, MAX_PITCH_ANGLE
	)
	
	var _last_yaw : float = rotation.y
	rotation.y = wrapf(rotation.y + look.x, 0.0, 6.283185)
	
	if abs(_last_pitch - _inner_gimble.rotation.x) <= FLOAT_THRESHOLD:
		pitch_changed.emit(_inner_gimble.rotation.x)
	if abs(_last_yaw - rotation.y) < FLOAT_THRESHOLD:
		yaw_changed.emit(rotation.y)


func _UpdateCameraProperties() -> void:
	if _camera == null: return
	_camera.attributes = attributes
	_camera.current = current
	_camera.fov = fov
	_camera.near = near
	_camera.far = far

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
