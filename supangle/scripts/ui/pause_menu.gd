extends Control
## Duraklatma menüsü: bölüm içinde ESC ile açılır, oyunu durdurur.
## Ekranı yarı saydam karartır; devam, ayarlar (ses/tam ekran) ve
## ana menüye dönüş sunar. Oyun durdurulmuşken çalışır (process_mode: Always).

@onready var menu_box: Control = %MenuBox
@onready var settings_panel: Control = %SettingsPanel
@onready var volume_slider: HSlider = %VolumeSlider
@onready var fullscreen_check: CheckBox = %FullscreenCheck

func _ready() -> void:
	visible = false
	volume_slider.set_value_no_signal(Settings.master_volume * 100.0)
	fullscreen_check.set_pressed_no_signal(Settings.fullscreen)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if visible:
		if settings_panel.visible:
			_on_back_button_pressed()
		else:
			_close()
		get_viewport().set_input_as_handled()
	elif not get_tree().paused:
		# Oyunu başka bir menü (kart seçimi/diyalog) durdurmuşken açılmaz.
		_open()
		get_viewport().set_input_as_handled()

func _open() -> void:
	get_tree().paused = true
	menu_box.visible = true
	settings_panel.visible = false
	visible = true

func _close() -> void:
	visible = false
	get_tree().paused = false

func _on_resume_button_pressed() -> void:
	_close()

func _on_settings_button_pressed() -> void:
	menu_box.visible = false
	settings_panel.visible = true

func _on_back_button_pressed() -> void:
	settings_panel.visible = false
	menu_box.visible = true

## GameState sahne değiştirirken paused'u zaten kaldırır.
func _on_main_menu_button_pressed() -> void:
	GameState.go_to_main_menu()

func _on_volume_slider_value_changed(value: float) -> void:
	Settings.set_master_volume(value / 100.0)

func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	Settings.set_fullscreen(toggled_on)
