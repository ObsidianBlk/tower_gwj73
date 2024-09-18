@tool
extends Resource
class_name PointGraph2D

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var points : Array[Vector2]
@export var edges : Dictionary = {}

# ------------------------------------------------------------------------------
# Variables
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
func _FindPointIndex(point : Vector2) -> int:
	for idx : int in range(points.size()):
		if points[idx].is_equal_approx(point):
			return idx
	return -1

func _FindOrAddPointIndex(point : Vector2) -> int:
	var idx : int = _FindPointIndex(point)
	if idx < 0:
		idx = points.size()
		points.append(point)
	return idx

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func count_points() -> int:
	return points.size()

func count_edges() -> int:
	return edges.size()

func get_point_index(point : Vector2) -> int:
	return _FindPointIndex(point)

func add_edge(from : Vector2, to : Vector2, weight : float = 1.0) -> int:
	if from.is_equal_approx(to): return ERR_LINK_FAILED
	var idx1 : int = _FindOrAddPointIndex(from)
	var idx2 : int = _FindOrAddPointIndex(to)
	var eidx : Vector2i = Vector2i(min(idx1, idx2), max(idx1, idx2))
	if eidx in edges:
		return ERR_ALREADY_EXISTS
	
	edges[eidx] = weight
	return OK

func get_edge_index(from : Vector2, to : Vector2) -> Vector2i:
	if from.is_equal_approx(to) : return Vector2i.ZERO
	var idx1 : int = _FindPointIndex(from)
	var idx2 : int = _FindPointIndex(to)
	var eidx : Vector2i = Vector2i(min(idx1, idx2), max(idx1, idx2))
	if eidx in edges:
		return eidx
	return Vector2i.ZERO

func get_edge(eidx : Vector2i) -> Dictionary:
	if eidx in edges:
		return {
			"a": points[eidx.x],
			"b": points[eidx.y],
			"w": edges[eidx]
		}
	return {}

func get_edges() -> Array[Dictionary]:
	var elist : Array[Dictionary] = []
	for eidx : Vector2i in edges.keys():
		elist.append({
			"a": points[eidx.x],
			"b": points[eidx.y],
			"w": edges[eidx]
		})
	return elist

func get_edges_at_point(point : Vector2) -> Array[Vector2i]:
	var idx : int = _FindPointIndex(point)
	if idx < 0: return []
	
	return edges.keys().filter(func(eidx : Vector2i):
		return eidx.x == idx or eidx.y == idx
	)

func get_edge_weight(eidx : Vector2i) -> float:
	if eidx in edges:
		return edges[eidx]
	return 0.0

func set_edge_weight(eidx : Vector2i, weight : float) -> int:
	if not eidx in edges:
		return ERR_DOES_NOT_EXIST
	edges[eidx] = weight
	return OK

func get_connected_points(point : Vector2) -> Array[Vector2]:
	var pidx : int = _FindPointIndex(point)
	if pidx < 0: return []
	
	var elist : Array[Vector2i] = get_edges_at_point(point)
	var plist : Array[Vector2] = []
	for eidx : Vector2i in elist:
		if eidx.x != pidx:
			plist.append(points[eidx.x])
		elif eidx.y != pidx:
			plist.append(points[eidx.y])
	return plist

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
