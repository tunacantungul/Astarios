extends Control
## Seviye atlama kart menüsü. Oyun durdurulmuşken çalışır (process_mode: Always).
## Level scripti open() ile açar; oyuncu kart seçince card_chosen sinyali yayılır.

signal card_chosen(id: String)

var _option_ids: Array[String] = []

@onready var _buttons: Array[Button] = [%Card1, %Card2, %Card3]

func _ready() -> void:
	visible = false
	for i in _buttons.size():
		_buttons[i].pressed.connect(_on_card_pressed.bind(i))

## Kart kimliklerini alır, başlık/açıklamaları havuzdan doldurur ve menüyü gösterir.
func open(options: Array[String]) -> void:
	_option_ids = options
	for i in _buttons.size():
		var has_option := i < options.size()
		_buttons[i].visible = has_option
		if has_option:
			var info: Dictionary = GameState.upgrade_card_info(options[i])
			_buttons[i].text = "%s\n\n%s" % [info.title, info.desc]
	visible = true

func _on_card_pressed(index: int) -> void:
	visible = false
	card_chosen.emit(_option_ids[index])
