@tool
extends RefCounted
class_name Delaunay

# Adapted from code located at...
# https://github.com/AntoniiViter/Delaunay-Triangulation/tree/main

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _edges : Array[DLine] = []
var _tris : Array[DTriangle] = []

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
func _StoreEdge(e : DLine, edges : Array[DLine]) -> Array[DLine]:
	for edge : DLine in edges:
		if e.is_equal_approx(edge):
			return edges
	edges.append(e)
	return edges

func _AddPoint(v : Vector2, tris : Array[DTriangle]) -> Array[DTriangle]:
	# TODO: Finish reworking this...
	# https://github.com/jmespadero/pyDelaunay2D/blob/master/delaunay2D.py
	var bad : Array[DTriangle] = []
	
	for tri : DTriangle in tris:
		if tri.is_point_in_circum_circle(v):
			bad.append(tri)
	
	var t : DTriangle = bad[0]
	var e : DTriangle.Edge = DTriangle.Edge.V0V1
	#while t != null:
	#	pass
	
	#print("Out: ", tris.size(), "\n\n")
	return tris

func _GenInitialTriangles(points : Array[Vector2]) -> Array[DTriangle]:
	var vmin : Vector2 = Vector2.INF
	var vmax : Vector2 = -Vector2.INF
	
	for point : Vector2 in points:
		vmin.x = min(vmin.x, point.x)
		vmin.y = min(vmin.y, point.y)
		vmax.x = max(vmax.x, point.x)
		vmax.y = max(vmax.y, point.y)
	
	vmin -= Vector2(4.0, 4.0)
	vmax += Vector2(4.0, 4.0)
	
	var tris : Array[DTriangle] = []
	tris.append(DTriangle.new(
		Vector2(vmax.x, vmin.y),
		Vector2(vmin.x, vmin.y),
		Vector2(vmin.x, vmax.y)
	))
	
	tris.append(DTriangle.new(
		Vector2(vmin.x, vmax.y),
		Vector2(vmax.x, vmax.y),
		Vector2(vmax.x, vmin.y)
	))
	
	tris[0].store_if_neighbor(tris[1], true)
	
	return tris

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func generate(points : Array[Vector2]) -> void:
	var tris : Array[DTriangle] = _GenInitialTriangles(points)
	
	for point : Vector2 in points:
		tris = _AddPoint(point, tris)
	_tris = tris
	
	_edges.clear()
	for tri : DTriangle in _tris:
		_edges = _StoreEdge(DLine.new(tri.v0, tri.v1), _edges)
		_edges = _StoreEdge(DLine.new(tri.v1, tri.v2), _edges)
		_edges = _StoreEdge(DLine.new(tri.v2, tri.v0), _edges)
	
	#tris = tris.filter(func(tri : DTriangle):
	#	return not tri.is_equal_approx(super_tri)
	#)

func get_edge_count() -> int:
	return _edges.size()

func get_triangle_count() -> int:
	return _tris.size()

func get_edge(idx : int) -> DLine:
	if idx >= 0 and idx < _edges.size():
		return _edges[idx]
	return null

func get_triangle(idx : int) -> DTriangle:
	if idx >= 0 and idx < _tris.size():
		return _tris[idx]
	return null



# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
