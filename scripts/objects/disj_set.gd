@tool
extends RefCounted
class_name DisjSet


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _nodes : Array[Dictionary] = []

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _init(elements : int = 0) -> void:
	make_sets(elements)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func make_sets(elements : int) -> void:
	_nodes.clear()
	_nodes.resize(elements)
	for idx : int in range(_nodes.size()):
		_nodes[idx] = {"root":idx, "rank":0}

func find(item : int) -> int:
	if not (item >= 0 and item < _nodes.size()): return -1
	if _nodes[item].root != item:
		_nodes[item].root = find(_nodes[item].root)
		return _nodes[item].root
	return item

func union(a : int, b : int) -> void:
	var aset : int = find(a)
	var bset : int = find(b)
	
	if aset < 0 or bset < 0 or aset == bset:
		return
	
	if _nodes[aset].rank < _nodes[bset].rank:
		_nodes[aset].root = bset
	elif _nodes[bset].rank < _nodes[aset].rank:
		_nodes[bset].root = aset
	else:
		_nodes[bset].root = aset
		_nodes[aset].rank += 1
