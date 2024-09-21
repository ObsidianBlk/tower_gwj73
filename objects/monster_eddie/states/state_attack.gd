extends FSMState

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const ANIM_ATTACK : StringName = &"attack"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var projectile : PackedScene = null
@export var spawn_delay : float = 0.05
@export var spawn_point : Marker3D = null
@export var anim_sprite : AnimatedSprite3D = null

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _delay : float = 0.05

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
func _SpawnProjectile() -> void:
	if host == null or projectile == null or spawn_point == null: return
	if host.has_visible_node():
		var p : Node = projectile.instantiate()
		if p is Node3D:
			p.direction = host.get_direction_to_visible_node()
			host.add_sibling(p)
			p.position = spawn_point.global_position
		else:
			p.queue_free()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func enter(data : Dictionary = {}) -> void:
	print("Attack")
	if host != null:
		host.motion.y = 0.0
	if anim_sprite != null:
		if not anim_sprite.animation_finished.is_connected(_on_animation_finished):
			anim_sprite.animation_finished.connect(_on_animation_finished)
		anim_sprite.play(ANIM_ATTACK)
	_delay = spawn_delay
	super.enter(data)

func exit() -> void:
	if anim_sprite != null:
		if anim_sprite.animation_finished.is_connected(_on_animation_finished):
			anim_sprite.animation_finished.disconnect(_on_animation_finished)
	super.exit()

func update(delta : float) -> void:
	if _delay > 0.0:
		_delay -= delta
		if _delay < 0.0:
			_SpawnProjectile.call_deferred()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_animation_finished() -> void:
	request_state_change(&"Chase")
