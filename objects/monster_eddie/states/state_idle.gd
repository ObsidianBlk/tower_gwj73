extends FSMState

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const META_KEY_TARGET_NODE : StringName = &"target_node"

const ANIM_IDLE : StringName = &"idle"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var vision_area : VisionArea3D = null
@export var unified_player : ASpriteUnifiedPlayer3D = null

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# "Virtual" Public Methods
# ------------------------------------------------------------------------------
func enter(_data : Dictionary = {}) -> void:
	if vision_area != null:
		if not vision_area.target_detected.is_connected(_on_vision_target_detected):
			vision_area.target_detected.connect(_on_vision_target_detected)
		if not vision_area.target_lost.is_connected(_on_vision_target_lost):
			vision_area.target_lost.connect(_on_vision_target_lost)
	
	if unified_player != null:
		unified_player.play(ANIM_IDLE)

func exit() -> void:
	if vision_area != null:
		if vision_area.target_detected.is_connected(_on_vision_target_detected):
			vision_area.target_detected.disconnect(_on_vision_target_detected)
		if vision_area.target_lost.is_connected(_on_vision_target_lost):
			vision_area.target_lost.disconnect(_on_vision_target_lost)
	super.exit()

func update(_delta : float) -> void:
	if host == null: return
	var target : Node3D = host.get_metadata(META_KEY_TARGET_NODE)
	if target == null: return
	
	host.look_at(target.global_position)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_vision_target_detected(body : Node3D) -> void:
	if host == null: return
	if not host.has_metadata(META_KEY_TARGET_NODE):
		host.set_metadata(META_KEY_TARGET_NODE, body)

func _on_vision_target_lost() -> void:
	if host == null: return
	host.clear_metadata(META_KEY_TARGET_NODE)
