extends Node2D

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const COLOR_ROOM : Color = Color.CORNFLOWER_BLUE
const COLOR_ROOM_WALLS : Color = Color.STEEL_BLUE
const ROOM_WALL_WIDTH : float = 1.0

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var seed : int = 0


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _map : TowerMap = null
var _new_step : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _btn_generate: Button = %BTN_Generate
@onready var _slider_seed: HSlider = %SLIDER_Seed


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_map = TowerMap.new()
	_map.generation_step_completed.connect(_on_generation_step_completed)
	_map.generation_completed.connect(_on_generation_completed)
	_slider_seed.value = seed

func _draw() -> void:
	if _map == null: return
	for idx : int in _map.get_room_count():
		var r : Rect2 = _map.get_room_rect(idx)
		if r.size.x <= 0.0: continue
		draw_rect(r, COLOR_ROOM, true)
		draw_rect(r, COLOR_ROOM_WALLS, false, ROOM_WALL_WIDTH)
	
	var d : Delaunay = _map.get_delaunay()
	if d != null:
		for idx : int in range(d.get_edge_count()):
			var edge : DLine = d.get_edge(idx)
			if edge != null:
				draw_line(edge.from, edge.to, Color.BROWN, 1.0, true)

func _physics_process(delta: float) -> void:
	if _new_step:
		_new_step = false
		queue_redraw()
		_map.generate_step.call_deferred()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func generate() -> void:
	if _map == null: return
	_btn_generate.disabled = true
	_slider_seed.editable = false
	_map.clear()
	_map.seed = seed
	_map.generate_step()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_generation_step_completed(result : int) -> void:
	if result != OK:
		_new_step = true

func _on_generation_completed() -> void:
	_btn_generate.disabled = false
	_slider_seed.editable = true

func _on_btn_generate_pressed() -> void:
	generate()

func _on_slider_seed_value_changed(value: float) -> void:
	seed = int(value)
