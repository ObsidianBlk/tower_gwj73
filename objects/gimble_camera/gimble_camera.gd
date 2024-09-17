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

#const MIN_PITCH_ANGLE : float = -1.570796
#const MAX_PITCH_ANGLE : float = 1.570796

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
@export var relative_offset : Vector2

@export_subgroup("Pitch")
@export_range(-90.0, 90.0) var min_pitch_angle : float = -90.0:	set=set_min_pitch_angle
@export_range(-90.0, 90.0) var max_pitch_angle : float = 90.0:	set=set_max_pitch_angle

@export_subgroup("Zoom")
@export_range(0.0, 10.0, 0.001) var min_zoom = 1.0:			set=set_min_zoom
@export_range(0.0, 200.0, 0.001) var max_zoom = 20.0:		set=set_max_zoom

@export_subgroup("Follow Target")
@export var target : Node3D = null
@export var follow_speed : float = 0.0
@export var max_target_distance : float = 5.0

@export_subgroup("Misc")
@export_flags_3d_physics var clip_collision_mask : int = 1:	set=set_clip_collision_mask
@export var input_on_captured_only : bool = true

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _mouse_sensitivity : Vector2 = Vector2(0.025, 0.025)
var _look : Vector2 = Vector2.ZERO
var _zoom : float = 0.0

var _target_zoom : float = 0.0
var _clipped : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _camera: Camera3D = $InnerGimble/Camera3D
@onready var _inner_gimble: Node3D = $InnerGimble
@onready var _clip_cast: RayCast3D = $InnerGimble/ClipCast


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_min_zoom(z : float) -> void:
	if z >= 0.0 and z < 10.0:
		min_zoom = z
		if min_zoom > max_zoom:
			max_zoom = min_zoom
		if _target_zoom < min_zoom:
			_target_zoom = min_zoom

func set_max_zoom(z : float) -> void:
	if z >= 0.0 and z < 200.0:
		max_zoom = z
		if max_zoom < min_zoom:
			min_zoom = max_zoom
		if _target_zoom > max_zoom:
			_target_zoom = max_zoom

func set_min_pitch_angle(p : float) -> void:
	if p >= -90.0 and p <= 90.0:
		min_pitch_angle = p
		if min_pitch_angle > max_pitch_angle:
			max_pitch_angle = min_pitch_angle

func set_max_pitch_angle(p : float) -> void:
	if p >= -90.0 and p <= 90.0:
		max_pitch_angle = p
		if max_pitch_angle < min_pitch_angle:
			min_pitch_angle = max_pitch_angle

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

func set_clip_collision_mask(ccm : int) -> void:
	if ccm != clip_collision_mask:
		clip_collision_mask = ccm
		if _clip_cast != null:
			_clip_cast.collision_mask = ccm

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
	_CalculateTargetZoom(delta)
	
	if is_instance_valid(target):
		global_position = _CalculateFollowPosition(global_position, target.global_position, delta)

func _physics_process(delta: float) -> void:
	if _clip_cast == null or _camera == null: return
	var desired_camera_pos : Vector3 = Vector3(relative_offset.x, 0.0, _target_zoom)
	if not _clip_cast.target_position.is_equal_approx(desired_camera_pos):
		_clip_cast.target_position = desired_camera_pos
		_clip_cast.force_raycast_update()
	
	if abs(_inner_gimble.position.y - relative_offset.y) > FLOAT_THRESHOLD:
		_inner_gimble.position.y = relative_offset.y
	
	if _clip_cast.is_colliding():
		_clipped = true
		var cpoint : Vector3 = _clip_cast.get_collision_point()
		var norm : Vector3 = cpoint.direction_to(_clip_cast.global_position)
		_camera.global_position = cpoint + (norm * 0.2)
	elif _clipped or not _camera.position.is_equal_approx(desired_camera_pos):
		_clipped = false
		_camera.position = desired_camera_pos

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CalculateFollowPosition(fposition : Vector3, tposition : Vector3, delta : float) -> Vector3:
	var final_position : Vector3 = tposition # Assume we snap to the target position
	# If we have no follow_speed, just snap to the target position... which, we already assumed.
	if follow_speed > 0.0:
		# Find the distance to the target
		# NOTE: Distance is only on the XZ plane!!
		var dist : float = fposition.distance_to(tposition)
		if max_target_distance > 0.0 and dist > max_target_distance:
			# If the distance if greater than max_target_distance, snap to within max_target_distance
			# of the target
			var vdir : Vector3 = (tposition - fposition).normalized()
			final_position = tposition + (vdir * max_target_distance)
		else:
			var max_unit_dist : float = follow_speed * delta
			var weight : float = min(1.0, max_unit_dist/dist)
			final_position = lerp(fposition, tposition, weight)
	
	return final_position

func _CalculateTargetZoom(delta : float) -> void:
	var _last_z : float = _target_zoom
	_target_zoom = max(min_zoom, min(max_zoom, _target_zoom + (ZOOM_RATE * _zoom * delta)))
	if abs(_last_z - _target_zoom) < FLOAT_THRESHOLD:
		_clip_cast.target_position.z = _target_zoom
		zoom_changed.emit(_target_zoom)

func _UpdateRotations(look : Vector2) -> void:
	var _last_pitch : float = _inner_gimble.rotation.x
	_inner_gimble.rotation.x = clamp(
		_inner_gimble.rotation.x + look.y,
		deg_to_rad(min_pitch_angle), deg_to_rad(max_pitch_angle)
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
