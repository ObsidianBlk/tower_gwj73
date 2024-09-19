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
@onready var _lbl_seed: Label = %LBL_Seed


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
	
	#var tsize : float = 100.0
	#var t : DTriangle = DTriangle.new(
		#Vector2(0.0, tsize),
		#Vector2(tsize, -tsize),
		#Vector2(-tsize, -tsize)
	#)
	
	var hw : Array[Dictionary] = _map.get_hallways()
	if hw.size() > 0:
		for info : Dictionary in hw:
			draw_line(info.s, info.e, Color.BLUE, 1.1, true)
	else:
		var d : Delaunay = _map.get_delaunay()
		if d != null:
			for idx : int in range(d.get_triangle_count()):
				var tri : DTriangle = d.get_triangle(idx)
				_DrawTriangle(tri, Color.AQUA)
		
		var g : PointGraph2D = _map.get_graph()
		if g != null:
			var edges : Array[Dictionary] = g.get_edges()
			for einfo : Dictionary in edges:
				draw_line(einfo.a, einfo.b, Color.CHARTREUSE, 1.0, true)
			
			var mst : Array[Vector2i] = _map.get_room_mst()
			for e : Vector2i in mst:
				draw_line(g.points[e.x], g.points[e.y], Color.RED, 1.1, true)


func _physics_process(delta: float) -> void:
	if _new_step:
		_new_step = false
		queue_redraw()
		_map.generate_step.call_deferred()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _DrawTriangle(t : DTriangle, color : Color, width : float = 1.0) -> void:
	draw_line(t.v0, t.v1, color, width)
	draw_line(t.v1, t.v2, color, width)
	draw_line(t.v2, t.v0, color, width)
	#draw_circle(t.v0, 2.0, Color.ALICE_BLUE, true)
	#draw_circle(t.v1, 2.0, Color.ALICE_BLUE, true)
	#draw_circle(t.v2, 2.0, Color.ALICE_BLUE, true)
	#draw_circle(t.circum_center, 4.0, Color.TOMATO, true)
	#draw_circle(t.circum_center, t.circum_radius, Color.SALMON, false, 1.0, true)

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
	_lbl_seed.text = "%d"%[seed]
