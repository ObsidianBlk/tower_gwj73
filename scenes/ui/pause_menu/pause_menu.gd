extends UIControl


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var options_menu : StringName = &""

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _slide_menu: SlideoutContainer = $SlideMenu
@onready var _btn_resume: Button = %BTN_Resume


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func on_reveal() -> void:
	_slide_menu.slide_amount = 1.0
	_slide_menu.slide_in()
	await _slide_menu.slide_finished
	_btn_resume.grab_focus()
	super.on_reveal()

func on_hide() -> void:
	_slide_menu.slide_amount = 0.0
	_slide_menu.slide_out()
	await _slide_menu.slide_finished
	super.on_hide()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_btn_resume_pressed() -> void:
	await pop_ui()
	request(UIAT.ACtION_RESUME_GAME)

func _on_btn_options_pressed() -> void:
	if options_menu.is_empty(): return
	await pop_ui()
	open_ui(options_menu, false, {UIControl.OPTION_PREVIOUS_MENU : name})

func _on_btn_quit_pressed() -> void:
	await pop_ui()
	request(UIAT.ACTION_QUIT_GAME)
