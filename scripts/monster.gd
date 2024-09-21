extends Actor
class_name Monster

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var turn_degrees_sec : float = 180.0
@export var vision_area : VisionArea3D = null:				set=set_vision_area

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var turn_rate : float = 0.0
var _vision_target_node : Node3D = null
var _facing_position : Vector3 = Vector3.ZERO

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_vision_area(va : VisionArea3D) -> void:
	_DisconnectVisionArea()
	vision_area = va
	_ConnectVisionArea()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectVisionArea() -> void:
	if vision_area == null: return
	if not vision_area.target_detected.is_connected(_on_vision_target_detected):
		vision_area.target_detected.connect(_on_vision_target_detected)
	if not vision_area.target_lost.is_connected(_on_vision_target_lost):
		vision_area.target_lost.connect(_on_vision_target_lost)

func _DisconnectVisionArea() -> void:
	if vision_area == null: return
	if vision_area.target_detected.is_connected(_on_vision_target_detected):
		vision_area.target_detected.disconnect(_on_vision_target_detected)
	if vision_area.target_lost.is_connected(_on_vision_target_lost):
		vision_area.target_lost.disconnect(_on_vision_target_lost)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func set_facing_position(fp : Vector3) -> void:
	_facing_position = fp

func get_facing_position() -> Vector3:
	return _facing_position

func get_angle_to_facing_position() -> float:
	if global_position.distance_to(_facing_position) >= 1.0:
		var dir : Vector3 = global_position - _facing_position
		return basis.z.signed_angle_to(dir, Vector3.UP)
	return 0.0

func face_visible_target() -> void:
	if _vision_target_node != null:
		_facing_position = _vision_target_node.global_position

func update_facing(delta : float) -> void:
	#print("Dist: ", global_position.distance_to(_facing_position))
	var tds : float = deg_to_rad(turn_degrees_sec) * delta * turn_rate
	var angle : float = get_angle_to_facing_position()
	if abs(angle) > tds:
		angle = clampf(angle, -tds, tds)
	rotate_y(angle)

func get_angle_to_visible() -> float:
	if _vision_target_node != null:
		if global_position.distance_to(_vision_target_node.global_position) > 1.0:
			var dir : Vector3 = global_position - _vision_target_node.global_position
			return basis.z.signed_angle_to(dir, Vector3.UP)
	return 0.0

func get_direction_to_visible_node() -> Vector3:
	if _vision_target_node != null:
		return _vision_target_node.global_position - global_position
	return Vector3.ZERO

func get_visible_node() -> Node3D:
	return _vision_target_node

func has_visible_node() -> bool:
	return _vision_target_node != null

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_vision_target_detected(body : Node3D) -> void:
	if _vision_target_node == null:
		_vision_target_node = body

func _on_vision_target_lost() -> void:
	_vision_target_node = null
