extends Node
## Kullanıcı ayarları: ses seviyesi ve tam ekran.
## user://settings.cfg dosyasına kaydedilir, açılışta otomatik yüklenir.

const CONFIG_PATH := "user://settings.cfg"

var master_volume: float = 1.0
var fullscreen: bool = true

func _ready() -> void:
	_load()
	_apply()

func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_apply()
	_save()

func set_fullscreen(value: bool) -> void:
	fullscreen = value
	_apply()
	_save()

func _apply() -> void:
	var bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(master_volume, 0.0001)))
	AudioServer.set_bus_mute(bus, master_volume <= 0.0)
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)

func _load() -> void:
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return
	master_volume = config.get_value("audio", "master_volume", 1.0)
	fullscreen = config.get_value("display", "fullscreen", true)

func _save() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("display", "fullscreen", fullscreen)
	config.save(CONFIG_PATH)
