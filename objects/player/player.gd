extends Actor

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var camera : GimbleCamera = null

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _is_idle : bool = true
var _idle_cooldown : float = 0.0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _asup: ASpriteUnifiedPlayer3D = $ASpriteUnifiedPlayer3D

# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: return
	
	if InputUtils.Event_Is_Action(event, [&"move_forward", &"move_back"]):
		motion.y = Input.get_axis(&"move_back", &"move_forward")
	if InputUtils.Event_Is_Action(event, [&"move_left", &"move_right"]):
		motion.x = Input.get_axis(&"move_left", &"move_right")

func _process(delta: float) -> void:
	if _asup != null:
		if velocity.length_squared() > 1.0:
			_asup.play(&"run")
			_is_idle = false
		elif not _is_idle:
			_is_idle = true
			_asup.play(&"idle")
		else:
			if _idle_cooldown <= 0.0 and randf() < 0.1:
				_idle_cooldown = randf_range(0.8, 1.2)
				if randf() < 0.5:
					_asup.play(&"idle_blink")
				else:
					_asup.play(&"idle_breath")
			elif _idle_cooldown > 0.0:
				_idle_cooldown -= delta
		
		if camera != null:
			if velocity.length_squared() > 1.0:
				rotation.y = camera.rotation.y

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
