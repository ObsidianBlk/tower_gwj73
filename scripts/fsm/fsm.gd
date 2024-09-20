extends Node
class_name FSM

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var host : Node = null:					set=set_host
@export var initial_state : StringName = &"":	set=set_initial_state

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _states : Dictionary = {}
var _active_state : FSMState = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_host(h : Node) -> void:
	if h != host:
		host = h

func set_initial_state(s : StringName) -> void:
	initial_state = s
	if _active_state == null:
		change_state(initial_state)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	for child : Node in get_children():
		_on_child_entered(child)
	change_state(initial_state)

func _unhandled_input(event: InputEvent) -> void:
	if _active_state:
		_active_state.handle_input(event)

func _process(delta: float) -> void:
	if _active_state:
		_active_state.update(delta)

func _physics_process(delta: float) -> void:
	if _active_state:
		_active_state.physics_update(delta)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectHostToChildren() -> void:
	for child : FSMState in _states.values():
		child.host = host

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func change_state(state_name : StringName, data : Dictionary = {}) -> void:
	if not state_name in _states: return
	if _active_state != null:
		if _active_state.name == state_name: return
		_active_state.request_exit()
		await _active_state.state_exited
		_active_state = null
	
	_active_state = _states[state_name]
	_active_state.enter(data)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_child_entered(child : Node) -> void:
	if child is FSMState and not (child.name in _states):
		if not child.state_change_requested.is_connected(change_state):
			child.state_change_requested.connect(change_state)
		child.host = host
		_states[child.name] = child

func _on_child_exiting(child : Node) -> void:
	if child is FSMState and child.name in _states:
		child.host = null
		if child.state_change_requested.is_connected(change_state):
			child.state_change_requested.disconnect(change_state)
