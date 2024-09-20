extends CharacterBody3D
class_name Actor

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var speed_forward : float = 8.0
@export var speed_back : float = 4.0
@export var speed_strafe : float = 6.0

@export var motion : Vector2 = Vector2.ZERO


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

var _meta : Dictionary = {}

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	var nvec_z : Vector3 = Vector3.ZERO
	nvec_z = basis.z * -(motion.y * (speed_forward if motion.y > 0.0 else speed_back))
	var nvec_x = basis.x * (motion.x * speed_strafe)
	
	velocity = (Vector3.DOWN * _gravity) + nvec_z + nvec_x
	move_and_slide()
	


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func clear_metadata(key : StringName) -> void:
	_meta.erase(key)

func clear_all_metadata() -> void:
	_meta.clear()

func has_metadata(key : StringName) -> bool:
	return key in _meta

func set_metadata(key : StringName, value : Variant) -> void:
	_meta[key] = value

func get_metadata(key : StringName, default : Variant = null) -> Variant:
	if key in _meta:
		return _meta[key]
	return default

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
