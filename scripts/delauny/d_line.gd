@tool
extends RefCounted
class_name DLine


# ------------------------------------------------------------------------------
# Public Variables
# ------------------------------------------------------------------------------
var from : Vector2 = Vector2.ZERO:		set=set_from
var to : Vector2 = Vector2.ZERO:		set=set_to

var a : float:							get=get_a
var b : float:							get=get_b
var c : float:							get=get_c

var pb_a : float:						get=get_pb_a
var pb_b : float:						get=get_pb_b
var pb_c : float:						get=get_pb_c

# ------------------------------------------------------------------------------
# Private Variables
# ------------------------------------------------------------------------------
var _a : float = 0.0
var _b : float = 0.0
var _c : float = 0.0

# Perpendicular Bisectors
var _pba : float = 0.0
var _pbb : float = 0.0
var _pbc : float = 0.0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_from(p : Vector2) -> void:
	from = p
	_UpdateLine()

func set_to(p : Vector2) -> void:
	to = p
	_UpdateLine()

func get_a() -> float:
	return _a

func get_b() -> float:
	return _b

func get_c() -> float:
	return _c

func get_pb_a() -> float:
	return _pba

func get_pb_b() -> float:
	return _pbb

func get_pb_c() -> float:
	return _pbc

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _init(f : Vector2 = Vector2.ZERO, t : Vector2 = Vector2.ZERO) -> void:
	from = f
	to = t

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateLine() -> void:
	_a = to.y - from.y
	_b = from.x - to.x
	_c = _a * from.x + _b * from.y
	
	var mid : Vector2 = Vector2(
		(from.x + to.x) * 0.5,
		(from.y + to.y) * 0.5
	)
	_pba = -_b
	_pbb = _a
	_pbc = (-_b * mid.x) + (_a * mid.y)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_circumcenter(b : DLine) -> Vector2:
	var determinant : float = _pba * b.pb_b - b.pb_a * _pbb
	if abs(determinant) < 0.001:
		return Vector2.INF
	return Vector2(
		(b.pb_b * _pbc - _pbb * b.pb_c) / determinant,
		(_pba * b.pb_c - b.pb_a * _pbc) / determinant
	)

func is_equal_approx(b : DLine) -> bool:
	return (from.is_equal_approx(b.from) and to.is_equal_approx(b.to)) or (from.is_equal_approx(b.to) and to.is_equal_approx(b.from))

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
