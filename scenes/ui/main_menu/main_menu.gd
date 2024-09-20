extends UIControl


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var options_menu : StringName = &""

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _btn_start: Button = %BTN_Start
@onready var _slide_menu: SlideoutContainer = $SlideMenu

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func on_reveal() -> void:
	_slide_menu.slide_amount = 1.0
	_slide_menu.slide_in()
	await _slide_menu.slide_finished
	_btn_start.grab_focus()
	super.on_reveal()

func on_hide() -> void:
	_slide_menu.slide_amount = 0.0
	_slide_menu.slide_out()
	await _slide_menu.slide_finished
	super.on_hide()


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_btn_start_pressed() -> void:
	await pop_ui()
	request(UIAT.ACTION_START_SINGLEPLAYER)

func _on_btn_options_pressed() -> void:
	if not options_menu.is_empty():
		await pop_ui()
		open_ui(options_menu, false, {UIControl.OPTION_PREVIOUS_MENU : name})

func _on_btn_quit_pressed() -> void:
	request(UIAT.ACTION_QUIT_APPLICATION)
