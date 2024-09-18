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
var _bounding_points : Array[Vector2] = []

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
			tri.set_metadata(&"bad", true)
			bad.append(tri)
	
	if bad.size() <= 0:
		return tris
	
	var boundry : Array = []
	var t : DTriangle = bad[0]
	var e : DTriangle.Edge = DTriangle.Edge.V0V1
	# Scan for all of the boundry edges
	while t != null:
		var t_op : DTriangle = t.get_neighbor_triangle(e)
		if t_op == null or bad.find(t_op) < 0:
			boundry.append({"edge": t.get_edge(e), "tri": t_op})
			e = DTriangle.Next_Edge(e)
			
			if boundry[0].edge.is_connected_from(boundry[-1].edge):
				t = null
		else:
			var ne : DTriangle.Edge = t_op.find_neighboring_edge(t)
			e = DTriangle.Next_Edge(ne)
			t = t_op
	
	# Remove the bad triangles
	tris = tris.filter(func(item : DTriangle):
		return not item.has_metadata(&"bad")
	)
	
	var tnew : Array[DTriangle] = []
	for item : Dictionary in boundry:
		var tri : DTriangle = DTriangle.new(v, item.edge.from, item.edge.to)
		tris.append(tri)
		if item.tri != null:
			tri.store_if_neighbor(item.tri, true)
		for ltri : DTriangle in tnew:
			ltri.store_if_neighbor(tri, true)
		tnew.append(tri)
	
	return tris

func _CalculatePointListBounds(points : Array[Vector2], buff_size : float = 0.0) -> Rect2:
	var vmin : Vector2 = Vector2.INF
	var vmax : Vector2 = -Vector2.INF
	
	for point : Vector2 in points:
		vmin.x = min(vmin.x, point.x)
		vmin.y = min(vmin.y, point.y)
		vmax.x = max(vmax.x, point.x)
		vmax.y = max(vmax.y, point.y)
	
	vmin -= Vector2(buff_size, buff_size)
	vmax += Vector2(buff_size, buff_size)
	
	return Rect2(vmin, vmax - vmin)
	

func _GenInitialTriangles(region : Rect2) -> Array[DTriangle]:
	var vmin : Vector2 = region.position
	var vmax : Vector2 = region.position + region.size
	
	_bounding_points = [
		Vector2(vmax.x, vmin.y),
		Vector2(vmin.x, vmin.y),
		Vector2(vmin.x, vmax.y),
		Vector2(vmax.x, vmax.y)
	]
	var tris : Array[DTriangle] = []
	tris.append(DTriangle.new(
		_bounding_points[0],
		_bounding_points[1],
		_bounding_points[2]
	))
	
	tris.append(DTriangle.new(
		_bounding_points[2],
		_bounding_points[3],
		_bounding_points[0]
	))
	
	tris[0].store_if_neighbor(tris[1], true)
	
	return tris

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func clear() -> void:
	_bounding_points.clear()
	_edges.clear()
	_tris.clear()

func generate(points : Array[Vector2]) -> void:
	clear()
	var region : Rect2 = _CalculatePointListBounds(points, 10.0)
	var tris : Array[DTriangle] = _GenInitialTriangles(region)
	
	for point : Vector2 in points:
		tris = _AddPoint(point, tris)
	
	# Only keep the triangles that don't share a vertex with the initial bounding box.
	_tris = tris.filter(func(item : DTriangle):
		return not (item.point_matches_vertex(_bounding_points[0]) or \
			item.point_matches_vertex(_bounding_points[1]) or \
			item.point_matches_vertex(_bounding_points[2]) or \
			item.point_matches_vertex(_bounding_points[3]))
	)
	
	for tri : DTriangle in _tris:
		_edges = _StoreEdge(DLine.new(tri.v0, tri.v1), _edges)
		_edges = _StoreEdge(DLine.new(tri.v1, tri.v2), _edges)
		_edges = _StoreEdge(DLine.new(tri.v2, tri.v0), _edges)
	
	#tris = tris.filter(func(tri : DTriangle):
	#	return not tri.is_equal_approx(super_tri)
	#)

func start_generate(points : Array[Vector2]) -> void:
	clear()
	var region : Rect2 = _CalculatePointListBounds(points, 10.0)
	_tris = _GenInitialTriangles(region)
	#_tris = [
		#DTriangle.Create_Containing_Triangle(points)
	#]

func end_generation() -> void:
	if _tris.size() > 0 and _bounding_points.size() > 0:
		# Only keep the triangles that don't share a vertex with the initial bounding box.
		_tris = _tris.filter(func(item : DTriangle):
			return not (item.point_matches_vertex(_bounding_points[0]) or \
				item.point_matches_vertex(_bounding_points[1]) or \
				item.point_matches_vertex(_bounding_points[2]) or \
				item.point_matches_vertex(_bounding_points[3]))
		)
		
		for tri : DTriangle in _tris:
			_edges = _StoreEdge(DLine.new(tri.v0, tri.v1), _edges)
			_edges = _StoreEdge(DLine.new(tri.v1, tri.v2), _edges)
			_edges = _StoreEdge(DLine.new(tri.v2, tri.v0), _edges)

func add_point(point : Vector2) -> int:
	if _tris.size() <= 0: return ERR_DOES_NOT_EXIST
	_tris = _AddPoint(point, _tris)
	return OK

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
