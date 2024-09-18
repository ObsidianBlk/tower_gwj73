extends FSMState

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const ANIM_RUN : StringName = &"run"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
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
func set_host(h : Node) -> void:
	if h == null or h is Actor:
		host = h

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# "Virtual" Public Methods
# ------------------------------------------------------------------------------
func enter(data : Dictionary = {}) -> void:
	if unified_player != null:
		unified_player.play(ANIM_RUN)

func handle_input(event : InputEvent) -> void:
	if host == null: return
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: return
	
	if InputUtils.Event_Is_Action(event, [&"move_forward", &"move_back"]):
		host.motion.y = Input.get_axis(&"move_back", &"move_forward")
	if InputUtils.Event_Is_Action(event, [&"move_left", &"move_right"]):
		host.motion.x = Input.get_axis(&"move_left", &"move_right")
	if event.is_action(&"fire_weapon"):
		if host.has_method("trigger"):
			host.trigger(event.is_pressed())
	if event.is_action_pressed("activate_slot_1"):
		if host.has_method("activate_slot"):
			host.activate_slot(1)

func update(delta : float) -> void:
	if host.velocity.length_squared() <= 0.1:
		request_state_change(&"Idle")

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
