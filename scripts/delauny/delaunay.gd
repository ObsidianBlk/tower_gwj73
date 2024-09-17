@tool
extends RefCounted
class_name Delaunay

# Adapted from code located at...
# https://github.com/AntoniiViter/Delaunay-Triangulation/tree/main

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _edges : Array[DLine] = []

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
func _StoreEdge(e : DLine) -> void:
	for edge : DLine in _edges:
		if e.is_equal_approx(edge):
			return # The given edge is not unique, don't add it!
	_edges.append(e)

func _AddPoint(v : Vector2, tris : Array[DTriangle]) -> Array[DTriangle]:
	tris = tris.filter(func (item : DTriangle):
		if item.is_point_in_circum_circle(v):
			_StoreEdge(DLine.new(item.v0, item.v1))
			_StoreEdge(DLine.new(item.v1, item.v2))
			_StoreEdge(DLine.new(item.v2, item.v0))
			return false
		return true
	)
	
	for edge : DLine in _edges:
		tris.append(DTriangle.new(edge.from, edge.to, v))
	return tris

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func generate(points : Array[Vector2]) -> void:
	var super_tri : DTriangle = DTriangle.Create_Containing_Triangle(points)
	var tris : Array[DTriangle] = [
		super_tri
	]
	
	for point : Vector2 in points:
		tris = _AddPoint(point, tris)
	
	_edges.clear()
	for tri : DTriangle in tris:
		if tri.is_equal_approx(super_tri): continue
		_StoreEdge(DLine.new(tri.v0, tri.v1))
		_StoreEdge(DLine.new(tri.v1, tri.v2))
		_StoreEdge(DLine.new(tri.v2, tri.v0))
	
	#tris = tris.filter(func(tri : DTriangle):
	#	return not tri.is_equal_approx(super_tri)
	#)

func get_edge_count() -> int:
	return _edges.size()

func get_edge(idx : int) -> DLine:
	if idx >= 0 and idx < _edges.size():
		return _edges[idx]
	return null

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
