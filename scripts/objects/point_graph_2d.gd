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

func _FindEdgesFromPointIndex(pidx : int) -> Array[Vector2i]:
	var arr : Array[Vector2i] = []
	arr.assign(edges.keys().filter(func(eidx : Vector2i):
		return eidx.x == pidx or eidx.y == pidx
	))
	return arr

func _BuildPathTo(idx : int, to_idx : int, visited : Array[int]) -> Array[Vector2]:
	var vto : Vector2 = points[to_idx]
	
	var edges : Array[Vector2i] = _FindEdgesFromPointIndex(idx)
	var process : bool = true
	
	while process:
		var nidx : int = -1
		var ndist : float = INF
		for edge : Vector2i in edges:
			var cidx : int = edge.x if edge.x != idx else edge.y
			if cidx == to_idx: # We found out destination!
				return [vto, points[idx]]
			if visited.find(cidx) < 0: # If point not visited...
				var dist : float = points[cidx].distance_to(vto)
				if dist < ndist:
					ndist = dist
					nidx = cidx
		
		if nidx >= 0:
			visited.append(nidx)
			var res : Array[Vector2] = _BuildPathTo(nidx, to_idx, visited)
			if not res.is_empty():
				res.append(points[idx])
				return res
		else:
			process = false
	return []

func _BuildMST(pidx : int, s : DisjSet, elist : Array[Vector2i]) -> Array[Vector2i]:
	var el : Array[Vector2i] = _FindEdgesFromPointIndex(pidx)
	var process : bool = true
	
	while process:
		var nidx : int = -1
		var ndist : float = INF
		for eidx : Vector2i in el:
			var idx : int = eidx.x if eidx.x != pidx else eidx.y
			if s.find(idx) != s.find(pidx):
				var dist : float = points[idx].distance_to(points[pidx])
				if dist < ndist:
					dist = ndist
					nidx = idx
		if nidx >= 0:
			s.union(nidx, pidx)
			elist.append(Vector2i(min(pidx, nidx), max(pidx, nidx)))
			_BuildMST(nidx, s, elist)
		else:
			process = false
		
	return elist

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func count_points() -> int:
	return points.size()

func count_edges() -> int:
	return edges.size()

func get_point(idx : int) -> Vector2:
	if idx >= 0 and idx < points.size():
		return points[idx]
	return Vector2.INF

func get_point_index(point : Vector2) -> int:
	return _FindPointIndex(point)

func has_edge(from : Vector2, to : Vector2) -> bool:
	var fidx : int = _FindPointIndex(from)
	var tidx : int = _FindPointIndex(to)
	if fidx < 0 or tidx < 0: return false
	
	var eidx : Vector2i = Vector2i(min(fidx, tidx), max(fidx, tidx))
	return eidx in edges

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
	return _FindEdgesFromPointIndex(idx)

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

func get_path_between(from : Vector2, to : Vector2) -> Array[Vector2]:
	var path : Array[Vector2] = []
	
	var fidx : int = _FindPointIndex(from)
	var tidx : int = _FindPointIndex(to)
	
	# If one or both points are missing, exit
	if fidx < 0 or tidx < 0: return []
	# If both points are the same, the path is a single point.
	if fidx == tidx: return [from]
	
	# If we have an edge between both points, then they're the path!
	if has_edge(from, to):
		return [from, to]
	
	var visited : Array[int] = [fidx]
	return _BuildPathTo(fidx, tidx, visited)
	
	return path

func get_minimum_spanning_tree(from : Vector2) -> Array[Vector2i]:
	var fidx : int = _FindPointIndex(from)
	if fidx < 0: return []
	
	var s : DisjSet = DisjSet.new(points.size())
	var elist : Array[Vector2i] = []
	elist = _BuildMST(fidx, s, elist)
	return elist


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
