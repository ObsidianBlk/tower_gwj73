@tool
extends RefCounted
class_name DTriangle


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
enum Edge {NONE=-1, V0V1=0, V1V2=1, V2V0=2, MAX=3}

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

# Weak references to neighbor DTriangle objects
var _nv0v1 : WeakRef = weakref(null)
var _nv1v2 : WeakRef = weakref(null)
var _nv2v0 : WeakRef = weakref(null)

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
	
	var dx : float = (vmax.x - vmin.x)
	var dy : float = (vmax.y - vmin.y)
	
	var v0 : Vector2 = Vector2(vmin.x - dx, vmin.y - dy * 3)
	var v1 : Vector2 = Vector2(vmin.x - dx, vmax.y + dy)
	var v2 : Vector2 = Vector2(vmax.x + dx * 3, vmax.y + dy)
	
	return DTriangle.new(v0, v1, v2)

static func Next_Edge(edge : Edge) -> Edge:
	match edge:
		Edge.V0V1:
			return Edge.V1V2
		Edge.V1V2:
			return Edge.V2V0
		Edge.V2V0:
			return Edge.V0V1
	return edge

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_point_in_circum_circle(point : Vector2) -> bool:
	return _cc.distance_to(point) <= circum_radius

func is_equal_approx(tri : DTriangle) -> bool:
	return (v0.is_equal_approx(tri.v0) and v1.is_equal_approx(tri.v1) and v2.is_equal_approx(tri.v2)) or \
		(v0.is_equal_approx(tri.v1) and v1.is_equal_approx(tri.v2) and v2.is_equal_approx(tri.v0)) or \
		(v0.is_equal_approx(tri.v2) and v1.is_equal_approx(tri.v0) and v2.is_equal_approx(tri.v1))

func get_edge(edge : Edge) -> DLine:
	match edge:
		Edge.V0V1:
			return DLine.new(v0, v1)
		Edge.V1V2:
			return DLine.new(v1, v2)
		Edge.V2V0:
			return DLine.new(v2, v0)
	return null


func do_edges_match(t : DTriangle, edge : Edge) -> bool:
	if t == null: return false
	var line : DLine = get_edge(edge)
	var tline : DLine = t.get_edge(edge)
	return line.is_equal_approx(tline)

func find_neighboring_edge(t : DTriangle) -> Edge:
	if do_edges_match(t, Edge.V0V1):
		return Edge.V0V1
	if do_edges_match(t, Edge.V1V2):
		return Edge.V1V2
	if do_edges_match(t, Edge.V2V0):
		return Edge.V2V0
	return Edge.NONE

func get_neighbor(edge : Edge) -> DTriangle:
	match edge:
		Edge.V0V1:
			return _nv0v1.get_ref()
		Edge.V1V2:
			return _nv1v2.get_ref()
		Edge.V2V0:
			return _nv2v0.get_ref()
	return null

func store_if_neighbor(t : DTriangle, reciprical : bool = false) -> int:
	var edge : Edge = find_neighboring_edge(t)
	if edge != Edge.NONE:
		match edge:
			Edge.V0V1:
				_nv0v1 = weakref(t)
			Edge.V1V2:
				_nv1v2 = weakref(t)
			Edge.V2V0:
				_nv2v0 = weakref(t)
		if reciprical:
			t.store_if_neighbor(self, false)
		return OK
	
	return ERR_INVALID_DATA

func point_matches_vertex(point : Vector2) -> bool:
	return point.is_equal_approx(v0) or point.is_equal_approx(v1) or point.is_equal_approx(v2)

func any_shared_vertex(tri : DTriangle) -> bool:
	return point_matches_vertex(tri.v0) or point_matches_vertex(tri.v1) or point_matches_vertex(tri.v2)

func as_string() -> String:
	return "V0: %v\nV1: %v\nV2: %v\n\n"%[v0, v1, v2]

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
