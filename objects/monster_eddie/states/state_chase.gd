extends FSMState

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const CHASE_ANGLE : float = deg_to_rad(10.0)

const ATTACK_YES : StringName = &"ATTACK"
const ATTACK_NO : StringName = &"NO_ATTACK"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var agent : NavigationAgent3D = null
@export var debug_obj : CSGPrimitive3D = null

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _navigation_complete : bool = false
var _weighted_attack : WeightedRandomCollection = WeightedRandomCollection.new([
	{"ID": ATTACK_YES, "Weight": 1.0},
	{"ID": ATTACK_NO, "Weight": 40.0}
])

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
func _ConnectAgent() -> void:
	if agent == null: return
	if not agent.navigation_finished.is_connected(_on_agent_nav_finished):
		agent.navigation_finished.connect(_on_agent_nav_finished)

func _DisconnectAgent() -> void:
	if agent == null: return
	if agent.navigation_finished.is_connected(_on_agent_nav_finished):
		agent.navigation_finished.disconnect(_on_agent_nav_finished)

func _UpdateFacing() -> void:
	if host == null and agent != null: return
	host.set_facing_position(agent.get_next_path_position())

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func enter(data : Dictionary = {}) -> void:
	print("Chase")
	_ConnectAgent()
	_navigation_complete = false
	super.enter(data)

func exit() -> void:
	_DisconnectAgent()
	super.exit()

func update(delta : float) -> void:
	if host == null: return
	if not _navigation_complete:
		
		var angle : float = host.get_angle_to_facing_position()
		host.turn_rate = smoothstep(deg_to_rad(0.0), deg_to_rad(90), abs(angle))
		if abs(angle) < deg_to_rad(15.0):
			if host.motion.y < 1.0:
				host.motion.y = min(1.0, host.motion.y + delta)
		else:
			if host.motion.y > 0.1:
				host.motion.y = min(0.1, host.motion.y - delta)
		host.update_facing(delta)
		
		angle = host.get_angle_to_visible()
		if abs(angle) >= CHASE_ANGLE:
			if _weighted_attack.get_random() == ATTACK_YES:
				request_state_change(&"Attack")
		
	elif _navigation_complete and host.motion.y > 0.001:
		host.motion.y = max(0.0, host.motion.y - delta)

func physics_update(delta : float) -> void:
	if host == null: return
	if agent != null:
		if host.has_visible_node():
			if debug_obj != null:
				debug_obj.global_position = agent.get_next_path_position()
			var target : Node3D = host.get_visible_node()
			if not agent.target_position.is_equal_approx(target.global_position):
				_navigation_complete = false
				agent.set_target_position(target.global_position)
			host.set_facing_position(agent.get_next_path_position())
		elif agent.is_navigation_finished():
			_navigation_complete = true
			if host.motion.y < 0.001:
				request_state_change(&"Idle")

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_agent_nav_finished() -> void:
	_navigation_complete = true
