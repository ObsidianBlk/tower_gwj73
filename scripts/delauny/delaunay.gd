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
func _StoreEdge(e : DLine, edges : Array[DLine]) -> Array[DLine]:
	for edge : DLine in edges:
		if e.is_equal_approx(edge):
			return edges
	edges.append(e)
	return edges

func _AddPoint(v : Vector2, tris : Array[DTriangle]) -> Array[DTriangle]:
	var edges : Array[DLine] = []
	#print("In: ", tris.size())
	tris = tris.filter(func (item : DTriangle):
		if item.is_point_in_circum_circle(v):
			edges = _StoreEdge(DLine.new(item.v0, item.v1), edges)
			edges = _StoreEdge(DLine.new(item.v1, item.v2), edges)
			edges = _StoreEdge(DLine.new(item.v2, item.v0), edges)
			return false
		return true
	)
	#print("Filtered: ", tris.size())
	
	for edge : DLine in edges:
		tris.append(DTriangle.new(edge.from, edge.to, v))
	
	#print("Out: ", tris.size(), "\n\n")
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
		if tri.is_equal_approx(super_tri):
			print("Found Super Triangle")
			continue
		_edges = _StoreEdge(DLine.new(tri.v0, tri.v1), _edges)
		_edges = _StoreEdge(DLine.new(tri.v1, tri.v2), _edges)
		_edges = _StoreEdge(DLine.new(tri.v2, tri.v0), _edges)
	
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
