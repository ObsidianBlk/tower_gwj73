@tool
extends RefCounted
class_name DTriangle


# ------------------------------------------------------------------------------
# Public Variables
# ------------------------------------------------------------------------------
var v0 : Vector2 = Vector2.ZERO:		set=set_v0
var v1 : Vector2 = Vector2.ZERO:		set=set_v1
var v2 : Vector2 = Vector2.ZERO:		set=set_v2

var circum_center : Vector2:			get=get_circum_center
var circum_radius : float:				get=get_circum_radius

# ------------------------------------------------------------------------------
# Private Variables
# ------------------------------------------------------------------------------
var _cc : Vector2 = Vector2.ZERO

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_v0(v : Vector2) -> void:
	v0 = v
	_UpdateCircumCenter()

func set_v1(v : Vector2) -> void:
	v1 = v
	_UpdateCircumCenter()

func set_v2(v : Vector2) -> void:
	v2 = v
	_UpdateCircumCenter()

func get_circum_center() -> Vector2:
	return _cc

func get_circum_radius() -> float:
	return _cc.distance_to(v0)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _init(a : Vector2 = Vector2.ZERO, b : Vector2 = Vector2.ZERO, c : Vector2 = Vector2.ZERO) -> void:
	v0 = a
	v1 = b
	v2 = c

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateCircumCenter() -> void:
	var l1 : DLine = DLine.new(v0, v1)
	var l2 : DLine = DLine.new(v1, v2)
	_cc = l1.get_circumcenter(l2)

# ------------------------------------------------------------------------------
# Static Public Methods
# ------------------------------------------------------------------------------
static func Create_Containing_Triangle(points : Array[Vector2]) -> DTriangle:
	var vmin : Vector2 = Vector2.INF
	var vmax : Vector2 = -Vector2.INF
	
	for point : Vector2 in points:
		vmin.x = min(vmin.x, point.x)
		vmin.y = min(vmin.y, point.y)
		vmax.x = max(vmax.x, point.x)
		vmax.y = max(vmax.y, point.y)
	
	var dx : float = (vmax.x - vmin.x) * 10.0
	var dy : float = (vmax.y - vmin.y) * 10.0
	
	var v0 : Vector2 = Vector2(vmin.x - dx, vmin.y - dy * 3)
	var v1 : Vector2 = Vector2(vmin.x - dx, vmax.y + dy)
	var v2 : Vector2 = Vector2(vmax.x + dx * 3, vmax.y + dy)
	
	return DTriangle.new(v0, v1, v2)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_point_in_circum_circle(point : Vector2) -> bool:
	var v : Vector2 = _cc - point
	return v.length() <= circum_radius

func is_equal_approx(tri : DTriangle) -> bool:
	return (v0.is_equal_approx(tri.v0) and v1.is_equal_approx(tri.v1) and v2.is_equal_approx(tri.v2)) or \
		(v0.is_equal_approx(tri.v1) and v1.is_equal_approx(tri.v2) and v2.is_equal_approx(tri.v0)) or \
		(v0.is_equal_approx(tri.v2) and v1.is_equal_approx(tri.v0) and v2.is_equal_approx(tri.v1))

func as_string() -> String:
	return "V0: %v\nV1: %v\nV2: %v\n\n"%[v0, v1, v2]

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
