extends Area3D
class_name VisionArea3D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal target_detected(body : Node3D)
signal target_lost()

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var target_group : StringName = &""
@export var line_of_sight : RayCast3D = null
@export var ray_offset : Vector3 = Vector3.ZERO

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _body : WeakRef = weakref(null)
var _tracking : bool = false
var _los_body : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(_delta: float) -> void:
	var body : Node3D = _body.get_ref()
	if body == null and _tracking:
		_tracking = false
		target_lost.emit()
		return
	_CheckLineOfSight()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CheckLineOfSight() -> void:
	var body : Node3D = _body.get_ref()
	if line_of_sight == null or body == null: return
	line_of_sight.target_position = line_of_sight.to_local(body.global_position + ray_offset)
	line_of_sight.force_raycast_update()
	var colliding : bool = false
	if line_of_sight.is_colliding():
		colliding = line_of_sight.get_collider().is_in_group(target_group)
	
	if colliding and not _los_body:
		_los_body = true
		target_detected.emit(body)
	elif not colliding and _los_body:
		_los_body = false
		target_lost.emit()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_body_entered(body : Node3D) -> void:
	if target_group.is_empty(): return
	if body.is_in_group(target_group):
		if _body.get_ref() != null: 
			return # Only track one at a time!
		_body = weakref(body)
		_tracking = true
		if line_of_sight == null:
			target_detected.emit(body)
		else:
			_CheckLineOfSight.call_deferred()

func _on_body_exited(body : Node3D) -> void:
	if target_group.is_empty(): return
	if body.is_in_group(target_group):
		if _body.get_ref() == body:
			_body = weakref(null)
			_tracking = false
			_los_body = false
		target_lost.emit()
