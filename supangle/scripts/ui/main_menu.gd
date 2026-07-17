extends Control
## Ana menü: başlat, ayarlar (ses/tam ekran), emeği geçenler ve çıkış.

@onready var menu_box: Control = %MenuBox
@onready var settings_panel: Control = %SettingsPanel
@onready var credits_panel: Control = %CreditsPanel
@onready var volume_slider: HSlider = %VolumeSlider
@onready var fullscreen_check: CheckBox = %FullscreenCheck

func _ready() -> void:
	volume_slider.set_value_no_signal(Settings.master_volume * 100.0)
	fullscreen_check.set_pressed_no_signal(Settings.fullscreen)

func _on_start_button_pressed() -> void:
	GameState.start_new_game()

func _on_settings_button_pressed() -> void:
	menu_box.visible = false
	settings_panel.visible = true

func _on_credits_button_pressed() -> void:
	menu_box.visible = false
	credits_panel.visible = true

func _on_back_button_pressed() -> void:
	settings_panel.visible = false
	credits_panel.visible = false
	menu_box.visible = true

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_volume_slider_value_changed(value: float) -> void:
	Settings.set_master_volume(value / 100.0)

func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	Settings.set_fullscreen(toggled_on)
