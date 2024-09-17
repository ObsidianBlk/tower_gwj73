extends Resource
class_name TowerMap

# NOTE: Proc-Gen in this resource is based on ideas found...
# https://www.gamedeveloper.com/programming/procedural-dungeon-generation-algorithm


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal generation_step_completed(result : Error)
signal generation_completed()

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------

const MNX_MAP_RADIUS : Vector2 = Vector2(60.0, 100.0)
const MNX_ROOM_COUNT : Vector2i = Vector2i(5, 20)
const MNX_ROOM_WIDTH : Vector2i = Vector2i(10, 64)
const MNX_ROOM_HEIGHT : Vector2i = Vector2i(10, 64)

const GEN_FIELD_MAP_RADIUS : StringName = &"MapRadius"
const GEN_FIELD_ROOM_COUNT : StringName = &"RoomCount"
const GEN_FIELD_PUSH_ROOMS : StringName = &"PushRooms"
const GEN_FIELD_CALC_DEL : StringName = &"CalcDel"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var seed : int = 0:				set=set_seed


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

var _gendata : Dictionary = {}
var _rooms : Array[Dictionary] = []
var _delaunay : Delaunay = null

# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_seed(s : int) -> void:
	if s != seed:
		seed = s
		changed.emit()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GetRandomPoint() -> Vector2:
	if GEN_FIELD_MAP_RADIUS in _gendata:
		var t = 2.0 * PI * _rng.randf()
		var u = _rng.randf() + _rng.randf()
		var r = u if u <= 1.0 else 2.0 - u
		return Vector2(
			_gendata[GEN_FIELD_MAP_RADIUS] * r * cos(t),
			_gendata[GEN_FIELD_MAP_RADIUS] * r * sin(t)
		)
	return Vector2.ZERO

func _GenerateRoom() -> void:
	var p : Vector2 = floor(_GetRandomPoint())
	var w : int = _rng.randi_range(MNX_ROOM_WIDTH.x, MNX_ROOM_WIDTH.y)
	var h : int = _rng.randi_range(MNX_ROOM_HEIGHT.x, MNX_ROOM_HEIGHT.y)
	_rooms.append({
		"p":p, "w":w, "h":h
	})

func _PushRooms() -> int:
	var pushed : bool = false
	
	for cidx : int in range(_rooms.size()):
		var crm : Dictionary = _rooms[cidx]
		var cpoint : Vector2 = crm["p"]
		var crad : int = (Vector2(crm["w"], crm["h"]) * 0.5).length()
		
		var neighbors : int = 0
		var pushv : Vector2 = Vector2.ZERO
		
		for idx : int in range(_rooms.size()):
			if idx == cidx : continue
			var rm : Dictionary = _rooms[idx]
			var rad : int = (Vector2(rm["w"], rm["h"]) * 0.5).length()
			var point : Vector2 = rm["p"]
			
			var vdir : Vector2 = cpoint - point
			var trad : float = rad + crad
			if vdir.length() < trad:
				neighbors += 1
				pushv += vdir
		
		if neighbors > 0:
			pushv = pushv / float(neighbors)
			crm["push"] = pushv
			pushed = true
	
	if pushed:
		for idx : int in range(_rooms.size()):
			if "push" in _rooms[idx]:
				_rooms[idx]["p"] += floor(_rooms[idx]["push"])
				_rooms[idx].erase("push")
		return ERR_BUSY
	
	return OK

func _GetRoomLocations() -> Array[Vector2]:
	var plist : Array[Vector2] = []
	for idx : int in range(_rooms.size()):
		var r : Rect2 = get_room_rect(idx)
		plist.append(r.position)
	return plist


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func clear() -> void:
	_delaunay = null
	_rooms.clear()
	_gendata.clear()

func is_generating() -> bool:
	return generation_step_completed.is_connected(_on_generation_step_completed)

func generate_step() -> int:
	if _gendata.is_empty():
		_rng.seed = seed
		_gendata[GEN_FIELD_MAP_RADIUS] = _rng.randi_range(MNX_MAP_RADIUS.x, MNX_MAP_RADIUS.y)
		_gendata[GEN_FIELD_ROOM_COUNT] = _rng.randi_range(MNX_ROOM_COUNT.x, MNX_ROOM_COUNT.y)
		if not is_generating():
			changed.emit()
		generation_step_completed.emit(ERR_BUSY)
		return ERR_BUSY
	
	if GEN_FIELD_ROOM_COUNT in _gendata:
		_GenerateRoom()
		if _rooms.size() >= _gendata[GEN_FIELD_ROOM_COUNT]:
			_gendata.erase(GEN_FIELD_ROOM_COUNT)
			_gendata[GEN_FIELD_PUSH_ROOMS] = true
		if not is_generating():
			changed.emit()
		generation_step_completed.emit(ERR_BUSY)
		return ERR_BUSY
	
	elif GEN_FIELD_PUSH_ROOMS in _gendata:
		if _PushRooms() == OK:
			_gendata.erase(GEN_FIELD_PUSH_ROOMS)
			_gendata[GEN_FIELD_CALC_DEL] = true
		generation_step_completed.emit(ERR_BUSY)
		return ERR_BUSY
	
	elif GEN_FIELD_CALC_DEL in _gendata:
		_delaunay = Delaunay.new()
		_delaunay.generate(_GetRoomLocations())
		_gendata.erase(GEN_FIELD_CALC_DEL)
		generation_step_completed.emit(ERR_BUSY)
		return ERR_BUSY
	
	_gendata.clear() # We're done... clear the gendata object
	generation_step_completed.emit(OK)
	generation_completed.emit()
	return OK

func generate() -> void:
	if generation_step_completed.is_connected(_on_generation_step_completed):
		# If this signal is connected, we're actively generating.
		# Don't do a damn thing.
		return
	
	generation_step_completed.connect(_on_generation_step_completed)
	clear()
	generate_step.call_deferred()
	await generation_completed
	generation_step_completed.disconnect(_on_generation_step_completed)

func get_room_count() -> int:
	return _rooms.size()

func get_room_rect(idx : int) -> Rect2:
	if idx >= 0 and idx < _rooms.size():
		var size : Vector2 = Vector2(_rooms[idx]["w"], _rooms[idx]["h"])
		var pos : Vector2 = _rooms[idx]["p"] - (size * 0.5)
		return Rect2(pos, size)
	return Rect2(Vector2.ZERO, Vector2.ZERO)

func get_delaunay() -> Delaunay:
	return _delaunay

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_generation_step_completed(result : Error) -> void:
	if result == ERR_BUSY:
		generate_step.call_deferred()
