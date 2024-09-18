extends FSMState

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const ANIM_IDLE : StringName = &"idle"
const ANIM_IDLE_BLINK : StringName = &"idle_blink"
const ANIM_IDLE_BREATH : StringName = &"idle_breath"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var unified_player : ASpriteUnifiedPlayer3D = null

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _idle_cooldown : float = 0.0

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
		unified_player.play(ANIM_IDLE)

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
	if host == null: return
	if unified_player != null:
		if _idle_cooldown <= 0.0 and randf() < 0.1:
			_idle_cooldown = randf_range(0.8, 1.2)
			if randf() < 0.5:
				unified_player.play(&"idle_blink")
			else:
				unified_player.play(&"idle_breath")
		elif _idle_cooldown > 0.0:
			_idle_cooldown -= delta
	
	if host.velocity.length_squared() > 0.1:
		request_state_change(&"Move")

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
