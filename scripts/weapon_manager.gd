extends Node3D
class_name WeaponManager

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal weapon_slot_active(slot_idx : int)

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const SLOT_PROP_WEAPON : StringName = &"weapon"
const SLOT_PROP_AVAILABLE : StringName = &"available"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var slot_1 : Weapon = null:				set=set_slot_1
@export var slot_2 : Weapon = null:				set=set_slot_2
@export var slot_3 : Weapon = null:				set=set_slot_3
@export var slot_4 : Weapon = null:				set=set_slot_4

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _slots : Array[Dictionary] = [
	{SLOT_PROP_WEAPON: null, SLOT_PROP_AVAILABLE: true},
	{SLOT_PROP_WEAPON: null, SLOT_PROP_AVAILABLE: false},
	{SLOT_PROP_WEAPON: null, SLOT_PROP_AVAILABLE: false},
	{SLOT_PROP_WEAPON: null, SLOT_PROP_AVAILABLE: false},
	{SLOT_PROP_WEAPON: null, SLOT_PROP_AVAILABLE: false}
]
var _active_slot = 0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_slot_1(w : Weapon) -> void:
	_UpdateSlot(1, w)

func set_slot_2(w : Weapon) -> void:
	_UpdateSlot(2, w)

func set_slot_3(w : Weapon) -> void:
	_UpdateSlot(3, w)

func set_slot_4(w : Weapon) -> void:
	_UpdateSlot(4, w)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateSlot(idx : int, w : Weapon) -> void:
	if idx >= 1 and idx < _slots.size():
		if _active_slot == idx:
			_ShutdownActiveSlot()
		_slots[idx][SLOT_PROP_WEAPON] = w
		if w != null:
			w.visible = false
		if _active_slot == idx:
			_ShowActiveSlot()

func _ShutdownActiveSlot() -> void:
	if not (_active_slot > 0 and _active_slot < _slots.size()): return
	if _slots[_active_slot][SLOT_PROP_WEAPON] == null: return
	
	_slots[_active_slot][SLOT_PROP_WEAPON].active = false
	_slots[_active_slot][SLOT_PROP_WEAPON].visible = false

func _ShowActiveSlot() -> void:
	if not (_active_slot > 0 and _active_slot < _slots.size()): return
	if _slots[_active_slot][SLOT_PROP_WEAPON] == null: return
	_slots[_active_slot][SLOT_PROP_WEAPON].visible = true
	_slots[_active_slot][SLOT_PROP_WEAPON].active = false # Just to be sure
	weapon_slot_active.emit(_active_slot)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func activate_slot(idx : int) -> void:
	if not (idx >= -1 and idx < _slots.size()): return
	if _active_slot == idx : return
	_ShutdownActiveSlot()
	_active_slot = idx
	_ShowActiveSlot()

func cycle_slot_up() -> void:
	var idx = (_active_slot + 1) % _slots.size()
	activate_slot(idx)

func cycle_slot_down() -> void:
	var idx = wrapi(_active_slot + 1, 0, _slots.size() - 1)
	activate_slot(idx)

func trigger(active : bool) -> void:
	if _slots[_active_slot][SLOT_PROP_WEAPON] == null: return
	if not _slots[_active_slot][SLOT_PROP_WEAPON].visible: return
	_slots[_active_slot][SLOT_PROP_WEAPON].active = active

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
