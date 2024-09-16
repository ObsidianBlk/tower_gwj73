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
	for idx : int in _map.get_room_count():
		var r : Rect2 = _map.get_room_rect(idx)
		if r.size.x <= 0.0: continue
		draw_rect(r, COLOR_ROOM, true)
		draw_rect(r, COLOR_ROOM_WALLS, false, ROOM_WALL_WIDTH)

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
	_map.generate()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_generation_step_completed(result : int) -> void:
	queue_redraw()

func _on_generation_completed() -> void:
	_btn_generate.disabled = false
	_slider_seed.editable = true

func _on_btn_generate_pressed() -> void:
	generate()

func _on_slider_seed_value_changed(value: float) -> void:
	seed = int(value)
