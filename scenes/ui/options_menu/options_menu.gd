extends UIControl


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const AUDIO_BUS_MASTER : StringName = &"Master"
const AUDIO_BUS_SFX : StringName = &"SFX"
const AUDIO_BUS_MUSIC : StringName = &"Music"
const VOLUME_MAX_VALUE : float = 1000.0

const MOUSE_SENSITIVITY_MAX_VALUE : float = 1000.0

# -- AUDIO Constants
const SECTION_AUDIO : String = "AUDIO"
const KEY_AUDIO_MASTER : String = "volume_master"
const KEY_AUDIO_SFX : String = "volume_sfx"
const KEY_AUDIO_MUSIC : String = "volume_music"

const DEFAULT_AUDIO_MASTER : float = 1.0
const DEFAULT_AUDIO_SFX : float = 0.8
const DEFAULT_AUDIO_MUSIC : float = 0.5

# -- VISUALS Contants
const SECTION_VISUALS : String = "VISUALS"


# -- GAMEPLAY Contants
const SECTION_GAMEPLAY : String = "GAMEPLAY"
const KEY_GAMEPLAY_MSENS_X : String = "mouse_sens_x"
const KEY_GAMEPLAY_MSENS_Y : String = "mouse_sens_y"
const KEY_GAMEPLAY_INVERT_X : String = "mouse_invert_x"
const KEY_GAMEPLAY_INVERT_Y : String = "mouse_invert_y"

const DEFAULT_GAMEPLAY_MOUSE_SENSITIVITY_X : float = 0.5
const DEFAULT_GAMEPLAY_MOUSE_SENSITIVITY_Y : float = 0.5
const DEFAULT_GAMEPLAY_INVERT_X : bool = false
const DEFAULT_GAMEPLAY_INVERT_Y : bool = false

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _slide_sec_ops: SlideoutContainer = %SlideSecOps
@onready var _slide_sections: SlideoutContainer = %SlideSections

@onready var _btn_audio_sec: Button = %BTN_AudioSec
@onready var _btn_visual_sec: Button = %BTN_VisualSec
@onready var _btn_gameplay_sec: Button = %BTN_GameplaySec

@onready var _audio_section: GridContainer = %AudioSection
@onready var _gameplay_section: GridContainer = %GameplaySection

@onready var _slide_master: HSlider = %SLIDE_Master
@onready var _slide_sfx: HSlider = %SLIDE_SFX
@onready var _slide_music: HSlider = %SLIDE_Music

@onready var _slider_mouse_sens_x: HSlider = %SLIDER_MouseSensX
@onready var _slider_mouse_sens_y: HSlider = %SLIDER_MouseSensY
@onready var _check_mouse_invert_x: CheckBox = %CHECK_MouseInvertX
@onready var _check_mouse_invert_y: CheckBox = %CHECK_MouseInvertY



# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	Settings.reset.connect(_on_settings_reset)
	Settings.loaded.connect(_on_settings_loaded)
	Settings.value_changed.connect(_on_settings_value_changed)
	_UpdateActiveSection()
	super._ready()


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ResetAudio() -> void:
	Settings.set_value(SECTION_AUDIO, KEY_AUDIO_MASTER, DEFAULT_AUDIO_MASTER)
	Settings.set_value(SECTION_AUDIO, KEY_AUDIO_SFX, DEFAULT_AUDIO_SFX)
	Settings.set_value(SECTION_AUDIO, KEY_AUDIO_MUSIC, DEFAULT_AUDIO_MUSIC)

func _ResetGameplay() -> void:
	Settings.set_value(SECTION_GAMEPLAY, KEY_GAMEPLAY_INVERT_X, DEFAULT_GAMEPLAY_INVERT_X)
	Settings.set_value(SECTION_GAMEPLAY, KEY_GAMEPLAY_INVERT_Y, DEFAULT_GAMEPLAY_INVERT_Y)
	Settings.set_value(SECTION_GAMEPLAY, KEY_GAMEPLAY_MSENS_X, DEFAULT_GAMEPLAY_MOUSE_SENSITIVITY_X)
	Settings.set_value(SECTION_GAMEPLAY, KEY_GAMEPLAY_MSENS_Y, DEFAULT_GAMEPLAY_MOUSE_SENSITIVITY_Y)

func _UpdateAudioValue(key : String, value : float) -> void:
	match key:
		KEY_AUDIO_MASTER:
			_slide_master.value = value * VOLUME_MAX_VALUE
			_SetVolume(AUDIO_BUS_MASTER, value)
		KEY_AUDIO_SFX:
			_slide_sfx.value = value * VOLUME_MAX_VALUE
			_SetVolume(AUDIO_BUS_SFX, value)
		KEY_AUDIO_MUSIC:
			_slide_music.value = value * VOLUME_MAX_VALUE
			_SetVolume(AUDIO_BUS_MUSIC, value)

func _UpdateGameplayValue(key : String, value : Variant) -> void:
	match key:
		KEY_GAMEPLAY_INVERT_X:
			if typeof(value) == TYPE_BOOL:
				_check_mouse_invert_x.button_pressed = value
		KEY_GAMEPLAY_INVERT_Y:
			if typeof(value) == TYPE_BOOL:
				_check_mouse_invert_y.button_pressed = value
		KEY_GAMEPLAY_MSENS_X:
			if typeof(value) == TYPE_FLOAT:
				_slider_mouse_sens_x.value = clamp(value, 0.0, 1.0) * MOUSE_SENSITIVITY_MAX_VALUE
		KEY_GAMEPLAY_MSENS_Y:
			if typeof(value) == TYPE_FLOAT:
				_slider_mouse_sens_y.value = clamp(value, 0.0, 1.0) * MOUSE_SENSITIVITY_MAX_VALUE

func _LoadedAudio() -> void:
	_UpdateAudioValue(KEY_AUDIO_MASTER, Settings.get_value(SECTION_AUDIO, KEY_AUDIO_MASTER, DEFAULT_AUDIO_MASTER))
	_UpdateAudioValue(KEY_AUDIO_SFX, Settings.get_value(SECTION_AUDIO, KEY_AUDIO_SFX, DEFAULT_AUDIO_SFX))
	_UpdateAudioValue(KEY_AUDIO_MUSIC, Settings.get_value(SECTION_AUDIO, KEY_AUDIO_MUSIC, DEFAULT_AUDIO_MUSIC))

func _LoadedGameplay() -> void:
	_UpdateGameplayValue(
		KEY_GAMEPLAY_INVERT_X,
		Settings.get_value(SECTION_GAMEPLAY, KEY_GAMEPLAY_INVERT_X, DEFAULT_GAMEPLAY_INVERT_X)
	)
	_UpdateGameplayValue(
		KEY_GAMEPLAY_INVERT_Y,
		Settings.get_value(SECTION_GAMEPLAY, KEY_GAMEPLAY_INVERT_Y, DEFAULT_GAMEPLAY_INVERT_Y)
	)
	_UpdateGameplayValue(
		KEY_GAMEPLAY_MSENS_X,
		Settings.get_value(SECTION_GAMEPLAY, KEY_GAMEPLAY_MSENS_X, DEFAULT_GAMEPLAY_MOUSE_SENSITIVITY_X)
	)
	_UpdateGameplayValue(
		KEY_GAMEPLAY_MSENS_Y,
		Settings.get_value(SECTION_GAMEPLAY, KEY_GAMEPLAY_MSENS_Y, DEFAULT_GAMEPLAY_MOUSE_SENSITIVITY_Y)
	)

func _SetVolume(bus_name : StringName, value : float) -> bool:
	var busidx : int = AudioServer.get_bus_index(bus_name)
	if busidx < 0: return false
	
	AudioServer.set_bus_volume_db(busidx, linear_to_db(value))
	return true

func _GetVolume(bus_name : StringName) -> float:
	var busidx : int = AudioServer.get_bus_index(bus_name)
	if busidx >= 0:
		return db_to_linear(AudioServer.get_bus_volume_db(busidx)) * VOLUME_MAX_VALUE
	return 0.0

func _UpdateActiveSection() -> void:
	_audio_section.visible = _btn_audio_sec.button_pressed
	_gameplay_section.visible = _btn_gameplay_sec.button_pressed

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func on_reveal() -> void:
	_slide_sec_ops.slide_amount = 1.0
	_slide_sec_ops.slide_in()
	_slide_sections.slide_amount = 1.0
	_slide_sections.slide_in()
	await _slide_sec_ops.slide_finished
	_btn_audio_sec.grab_focus()
	super.on_reveal()

func on_hide() -> void:
	_slide_sec_ops.slide_amount = 0.0
	_slide_sec_ops.slide_out()
	_slide_sections.slide_amount = 0.0
	_slide_sections.slide_out()
	await _slide_sec_ops.slide_finished
	super.on_hide()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_settings_loaded() -> void:
	_LoadedAudio()
	_LoadedGameplay()

func _on_settings_reset() -> void:
	_ResetAudio()
	_ResetGameplay()

func _on_settings_value_changed(section : String, key : String, value : Variant) -> void:
	match section:
		SECTION_AUDIO:
			if typeof(value) == TYPE_FLOAT:
				_UpdateAudioValue(key, value)
		SECTION_GAMEPLAY:
			_UpdateGameplayValue(key, value)
		SECTION_VISUALS:
			pass

func _on_btn_audio_sec_pressed() -> void:
	if not _audio_section.visible:
		_slide_sections.slide_out()
		await _slide_sections.slide_finished
		_UpdateActiveSection()
		_slide_sections.slide_in()


func _on_btn_visual_sec_pressed() -> void:
	pass # Replace with function body.


func _on_btn_gameplay_sec_pressed() -> void:
	if not _gameplay_section.visible:
		_slide_sections.slide_out()
		await _slide_sections.slide_finished
		_UpdateActiveSection()
		_slide_sections.slide_in()


func _on_btn_apply_pressed() -> void:
	if Settings.is_dirty():
		Settings.save()
	pop_ui()


func _on_btn_back_pressed() -> void:
	if Settings.is_dirty():
		Settings.reload()
	pop_ui()


func _on_slide_master_value_changed(value: float) -> void:
	Settings.set_value(SECTION_AUDIO, KEY_AUDIO_MASTER, value / VOLUME_MAX_VALUE)

func _on_slide_sfx_value_changed(value: float) -> void:
	Settings.set_value(SECTION_AUDIO, KEY_AUDIO_SFX, value / VOLUME_MAX_VALUE)

func _on_slide_music_value_changed(value: float) -> void:
	Settings.set_value(SECTION_AUDIO, KEY_AUDIO_MUSIC, value / VOLUME_MAX_VALUE)

func _on_slider_mouse_sens_x_value_changed(value: float) -> void:
	Settings.set_value(SECTION_GAMEPLAY, KEY_GAMEPLAY_MSENS_X, value / MOUSE_SENSITIVITY_MAX_VALUE)

func _on_slider_mouse_sens_y_value_changed(value: float) -> void:
	Settings.set_value(SECTION_GAMEPLAY, KEY_GAMEPLAY_MSENS_Y, value / MOUSE_SENSITIVITY_MAX_VALUE)

func _on_check_mouse_invert_x_toggled(toggled_on: bool) -> void:
	Settings.set_value(SECTION_GAMEPLAY, KEY_GAMEPLAY_INVERT_X, toggled_on)

func _on_check_mouse_invert_y_toggled(toggled_on: bool) -> void:
	Settings.set_value(SECTION_GAMEPLAY, KEY_GAMEPLAY_INVERT_Y, toggled_on)
