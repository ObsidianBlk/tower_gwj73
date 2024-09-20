extends Control


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const INIT_LEVEL : String = "res://scenes/test_env/test_env.tscn"

const PAUSE_MENU : StringName = &"PauseMenu"

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _level : Node3D = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var ui: UILayer = $UI
@onready var screen_view: SubViewport = %ScreenView


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	ui.register_action_handler(UIAT.ACTION_QUIT_APPLICATION, _on_quit_application)
	ui.register_action_handler(UIAT.ACTION_START_SINGLEPLAYER, _on_start_game)
	ui.register_action_handler(UIAT.ACtION_RESUME_GAME, _on_resume_game)
	ui.register_action_handler(UIAT.ACTION_QUIT_GAME, _on_quit_game)
	if Settings.load() != OK:
		Settings.request_reset()
		Settings.save()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused and _level != null:
			ui.close_all_ui()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_tree().paused = false
		elif not get_tree().paused:
			if _level == null:
				print("Nothing to do with that yet")
				pass # Maybe ask if the player wants to quit the game
			else:
				get_tree().paused = true
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				ui.open_ui(PAUSE_MENU)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _DropLevel() -> void:
	if _level == null: return
	screen_view.remove_child(_level)
	_level.queue_free()
	_level = null

func _LoadLevel(level_src : String) -> int:
	var r : Resource = load(level_src)
	if r == null or not r is PackedScene:
		return ERR_FILE_UNRECOGNIZED
	var lv : Node = r.instantiate()
	if lv is Node3D:
		_DropLevel()
		_level = lv
		screen_view.add_child(_level)
		return OK
	lv.queue_free()
	return ERR_INVALID_DATA

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_quit_application() -> void:
	if Settings.is_dirty():
		Settings.save()
	get_tree().quit()

func _on_start_game() -> void:
	if _LoadLevel(INIT_LEVEL) == OK:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif _level == null:
		ui.open_default_ui()

func _on_resume_game() -> void:
	if get_tree().paused and _level != null:
		ui.close_all_ui()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_tree().paused = false

func _on_quit_game() -> void:
	if _level == null: return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_DropLevel()
	ui.open_default_ui()
